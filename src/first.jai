Basic :: #import "Basic";
Compiler :: #import "Compiler";
File :: #import "File";
String :: #import "String";

#load "../lava/modules/Sill/meta.jai";

#run () {
    Basic.set_working_directory(String.join(#filepath, "/.."));
    File.make_directory_if_it_does_not_exist("./bin");

    workspace := Compiler.compiler_create_workspace("hioy");

    options := Compiler.get_build_options();
    options.output_executable_name  = "hioy";
    options.output_path             = String.join(#filepath, "/../bin/");
    options.optimization_level      = .DEBUG;
    options.text_output_flags       = .OUTPUT_TIMING_INFO; // @note And not the linker lines.

    import_path: [..] string;
    Basic.array_add(*import_path, "./lava/bindings");
    Basic.array_add(*import_path, "./lava/modules");
    Basic.array_add(*import_path, ..options.import_path);
    options.import_path = import_path;

    // Building our main program
    Compiler.set_build_options(options, workspace);

    Compiler.compiler_begin_intercept(workspace);
    Compiler.add_build_file("./src/main.jai", workspace);

    while true {
        message := Compiler.compiler_wait_for_message();
        if !message break;
        if message.workspace != workspace continue;

        sill_meta_handle_message(message);

        if message.kind == .COMPLETE {
            break;
        }
    }

    Compiler.compiler_end_intercept(workspace);

    // Do not generate executable for this build program
    Compiler.set_build_options_dc(.{ do_output = false });
}();
