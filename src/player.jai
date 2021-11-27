PlayerEntity :: struct {
    using entity : Sill.Entity;
    behavior : Sill.BehaviorComponent;
    transform : Sill.TransformComponent;
    camera : Sill.CameraComponent;

    SerializedData :: struct {
        transform : Chamber.trf;
    }
}

PlayerCloneEntity :: struct {
    using entity : Sill.Entity;
    behavior : Sill.BehaviorComponent;
    transform : Sill.TransformComponent;
    mesh : Sill.MeshComponent;

    // @todo These are somewhat arbitrary, but based on human
    // central vision.
    FOV_X :: #run Chamber.to_radians(100);
    FOV_Y :: #run Chamber.to_radians(30);
}

playerPostProcessMaterial : *Magma.Material;

player_init :: () {
    if !game.vr.enabled {
        Crater.window_pointer_auto_centered(game.engine.window);
        Crater.window_pointer_hidden(game.engine.window);
    }

    Sill.input_action_bind(*game.engine.input, "player.select", .RightHandSelect);

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

    playerPostProcessShader := Magma.create_shader(game.engine.postProcessRenderer, "assets/shaders/post-processes/player");
    playerPostProcessMaterial = Magma.create_material(playerPostProcessShader);

    player := SillMeta.create_player_entity(game.engine);
    game.player = player;
    Sill.transform_translate(*player.transform, .{0, 0, 1.75});

    Sill.behavior_on_update(*player.behavior, xx (dt : float64, player : *PlayerEntity) {
        if game.vr.enabled {
            Sill.transform_set(*player.transform, game.engine.vrTarget.headInfo.transform);

            if Sill.input_action_just_activated(*game.engine.input, "player.select") {
                Chamber.debug("Player select.");
            }
            return;
        }

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

    // ----- Player clone

    playerClone := SillMeta.create_player_clone_entity(game.engine);
    game.playerClone = playerClone;

    Sill.transform_translate(*playerClone.transform, .{5, 0, 1.75});
    Sill.transform_rotate(*playerClone.transform, 0.95 * Math.PI, .{0, 0, 1});
    Sill.transform_rotate(*playerClone.transform, -0.05 * Math.PI, .{0, 1, 0});

    Sill.mesh_load_glb(*playerClone.mesh, "./assets/models/vr-headset.glb");

    Sill.behavior_on_update(*playerClone.behavior, xx (dt : float64, playerClone : *PlayerCloneEntity) {
        // Moving the player in the clone's view space
        // @todo There is probably a way to multiply the trf with the point directly, without going back to matrix.
        playerCloneViewMatrix := Chamber.make_matrix(Chamber.inverse(playerClone.transform));

        // @note We expect the relativePosition to be in
        // the player clone view's space.
        // The return value is a visibility value. The closer to 1, the more the player is visible,
        // and 0 means that the player is not visible.
        player_clone_visibility :: (relativePosition : $T/interface Vector3) -> float32 {
            longitudeAngle := Math.atan2(relativePosition.y, relativePosition.x);
            latitudeAngle := Math.atan2(relativePosition.z, Math.length(relativePosition.xy));
            longitudeVisibility := (1. - Math.abs(longitudeAngle) / (PlayerCloneEntity.FOV_X / 2.));
            latitudeVisibility := (1. - Math.abs(latitudeAngle) / (PlayerCloneEntity.FOV_Y / 2.));
            if longitudeVisibility > 0. && latitudeVisibility > 0. {
                longitudeVisibility = ifx longitudeVisibility < 0.5 then longitudeVisibility * 2 else 1;
                latitudeVisibility = ifx latitudeVisibility < 0.5 then latitudeVisibility * 2 else 1;
                value := longitudeVisibility * latitudeVisibility;
                return longitudeVisibility * latitudeVisibility;
            }
            return 0.;
        };

        power : float32 = 0.;

        // @note We test the visibility on multiple points from the head to the ground.
        // The number of points is this value below. This hard coded value allows for
        // samples to be spaced by around 10cm each.
        PLAYER_VISIBILITY_SAMPLES_COUNT :: 20;
        // @todo We put the feet at height 0, it may just be wrong.
        playerHeadPosition := game.player.transform.translation;
        playerFeetPosition := Chamber.make_vec3(game.player.transform.translation.xy, 0);

        for i : 0 .. PLAYER_VISIBILITY_SAMPLES_COUNT - 1 {
            position := Chamber.mix(playerHeadPosition, playerFeetPosition, (cast(float32) i) / (PLAYER_VISIBILITY_SAMPLES_COUNT - 1));
            relativeToClonePosition := playerCloneViewMatrix * Chamber.make_vec4(position, 1);
            power = Chamber.max(power, player_clone_visibility(relativeToClonePosition));
            if power == 1. {
                break;
            }
        }

        Magma.material_set(playerPostProcessMaterial, "power", power);
    }, playerClone);
}

#scope_file

Math :: #import "Math";
Magma :: #import "Magma";
