// #import "Basic"()(MEMORY_DEBUGGER=true);

Basic :: #import "Basic";
Sill :: #import "Sill";
Chamber :: #import "Chamber";

#load "player.jai";

// @note We're using a global variable to store
// the global state of the game. We could be passing
// a variable around to each function, but that seems
// overkill when a global variable would do the job just fine.
game : struct {
    engine : *Sill.Engine(SillMeta);
}

main :: () {
    game.engine = Sill.create_engine(SillMeta);

    player_init();

    Sill.engine_run(game.engine);

    // Basic.report_memory_leaks();
}

#scope_file

#import "Math";
