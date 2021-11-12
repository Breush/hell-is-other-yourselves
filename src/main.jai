// #import "Basic"()(MEMORY_DEBUGGER=true);

Basic :: #import "Basic";
Sill :: #import "Sill";
Crater :: #import "Crater";
Chamber :: #import "Chamber";

#load "ground.jai";
#load "player.jai";
#load "recorder.jai";

// @note We're using a global variable to store
// the global state of the game. We could be passing
// a variable around to each function, but that seems
// overkill when a global variable would do the job just fine.
game : struct {
    engine : *Sill.Engine(SillMeta);

    player : *PlayerEntity;
    playerClone : *PlayerCloneEntity;
    recorder : *RecorderEntity;
}

main :: () {
    game.engine = Sill.create_engine(SillMeta);

    ground_init();
    player_init();
    recorder_init();

    Sill.engine_run(game.engine);

    // cleanup();
    // Basic.report_memory_leaks();
}

#scope_file

cleanup :: () {
    recorder_cleanup();

    Sill.destroy_engine(game.engine);
}

#import "Math";
