PlayerEntity :: struct {
    using entity : Sill.Entity;
    behavior : Sill.BehaviorComponent;
    transform : Sill.TransformComponent;
    camera : Sill.CameraComponent;
}

player_init :: () {
    Crater.window_pointer_auto_centered(game.engine.window);
    Crater.window_pointer_hidden(game.engine.window);

    // @note For Azerty keyboards, but that's temporary.
    // Anyway, the game is meant to be player in VR.
    Sill.input_action_bind(*game.engine.input, "player.forward", .Z);
    Sill.input_action_bind(*game.engine.input, "player.backward", .S);
    Sill.input_action_bind(*game.engine.input, "player.left", .Q);
    Sill.input_action_bind(*game.engine.input, "player.right", .D);
    Sill.input_action_bind(*game.engine.input, "player.forward", .Up);
    Sill.input_action_bind(*game.engine.input, "player.backward", .Down);
    Sill.input_action_bind(*game.engine.input, "player.left", .Left);
    Sill.input_action_bind(*game.engine.input, "player.right", .Right);
    Sill.input_action_bind(*game.engine.input, "player.up", .Space);
    Sill.input_action_bind(*game.engine.input, "player.down", .ShiftLeft);

    Sill.input_axis_bind(*game.engine.input, "player.look-horizontal", .MousePointerX);
    Sill.input_axis_bind(*game.engine.input, "player.look-vertical", .MousePointerY);

    player := SillMeta.create_player_entity(game.engine);
    Sill.transform_translate(*player.transform, .{0, 0, 1.75});

    Sill.behavior_on_update(*player.behavior, xx (dt : float64, player : *PlayerEntity) {
        impulse : Chamber.vec3;
        if Sill.input_action_active(*game.engine.input, "player.forward") {
            impulse.std += .{3, 0, 0}; // 3 meters per second
        }
        if Sill.input_action_active(*game.engine.input, "player.backward") {
            impulse.std += .{-2.8, 0, 0};
        }
        if Sill.input_action_active(*game.engine.input, "player.left") {
            impulse.std += .{0, 2.8, 0};
        }
        if Sill.input_action_active(*game.engine.input, "player.right") {
            impulse.std += .{0, -2.8, 0};
        }
        if Sill.input_action_active(*game.engine.input, "player.up") {
            impulse.std += .{0, 0, 1.4};
        }
        if Sill.input_action_active(*game.engine.input, "player.down") {
            impulse.std += .{0, 0, -1.4};
        }

        // @todo Handle mouse sensibility
        lookX := Sill.input_axis_value(*game.engine.input, "player.look-horizontal");
        if lookX != 0. {
            Sill.transform_rotate(*player.transform, -lookX / 314.16, .{0, 0, 1});
        }

        lookY := Sill.input_axis_value(*game.engine.input, "player.look-vertical");
        if lookY != 0. {
            localLeft : Chamber.vec3;
            localLeft.std = rotate(.{0, 1, 0}, player.transform.rotation);
            Sill.transform_rotate(*player.transform, lookY / 314.16, localLeft);
        }

        // @todo Be clearer, what is local-space translate vs world-space translate.
        // And does local mean relative to parent or to self? And see, here we're doing stuff
        // to constrain on Z.
        impulse.std *= cast(float32) dt;
        impulse.std = rotate(impulse, player.transform.rotation);
        impulse.std.z = 0.;
        Sill.transform_translate(*player.transform, impulse);
    }, player);
}
