PlayerEntity :: struct {
    using entity : Sill.Entity;
    behavior : Sill.BehaviorComponent;
    transform : Sill.TransformComponent;
    mesh : Sill.MeshComponent;
}

// @fixme Attach a camera component to the Player,
// taking the transform of it automatically for the position.

player_init :: () {
    // @note For Azerty keyboards, but that's temporary.
    // Anyway, the game is meant to be player in VR.
    Sill.input_action_bind(*game.engine.input, "player.forward", .Z);
    Sill.input_action_bind(*game.engine.input, "player.backward", .S);
    Sill.input_action_bind(*game.engine.input, "player.left", .Q);
    Sill.input_action_bind(*game.engine.input, "player.right", .D);

    player := game.engine.Meta.create_player_entity(game.engine);

    Sill.mesh_load_glb(*player.mesh, "/home/sherlock/dev/lava-jai/assets/models/corset.glb"); // @fixme...
    Sill.transform_scale(*player.transform, 20);
    Sill.transform_rotate(*player.transform, 3.1416, .{0, 0, 1});

    Sill.behavior_on_update(*player.behavior, xx (dt : float64, player : *PlayerEntity) {
        impulse : Chamber.vec3;
        // @fixme Be clearer, what is local-space translate vs world-space translate.
        // And does local mean relative to parent or to self?
        if Sill.input_active(*game.engine.input, "player.forward") {
            impulse = .{3, 0, 0}; // 3 meters per second
        } else if Sill.input_active(*game.engine.input, "player.backward") {
            impulse = .{-2.8, 0, 0};
        } else if Sill.input_active(*game.engine.input, "player.left") {
            impulse = .{0, 2.8, 0};
        } else if Sill.input_active(*game.engine.input, "player.right") {
            impulse = .{0, -2.8, 0};
        }
        impulse.std *= cast(float32) dt;
        Sill.transform_translate(*player.transform, impulse);
    }, player);
}
