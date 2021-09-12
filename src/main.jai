// #import "Basic"()(MEMORY_DEBUGGER=true);

Basic :: #import "Basic";
Sill :: #import "Sill";

DummyEntity :: struct {
    using entity : Sill.Entity;
}

main :: () {
    engine := Sill.create_engine(SillMeta);

    Sill.engine_run(engine);

    // Basic.report_memory_leaks();
}
