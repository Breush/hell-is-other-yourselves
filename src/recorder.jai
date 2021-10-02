RecorderEntity :: struct {
    using entity : Sill.Entity;
    behavior : Sill.BehaviorComponent;

    mode : enum {
        Idle;
        Recording;
        Pause;
        Replay;
    };

    WorldState :: struct {
        player : PlayerEntity.SerializedData;
    }
    worldStates : [..]WorldState;

    replayCurrentFrame : u32;
}

recorder_init :: () {
    recorder := SillMeta.create_recorder_entity(game.engine);
    recorder.mode = .Idle;

    Sill.input_action_bind(*game.engine.input, "recorder.record", .R);
    Sill.input_action_bind(*game.engine.input, "recorder.replay", .R);

    // @note Allocating 40MB of memory.
    Basic.array_reserve(*recorder.worldStates, 40_000_000 / size_of(RecorderEntity.WorldState));

    Chamber.debug("[Recorder] Currently idle. Press R to record.");

    Sill.behavior_on_update(*recorder.behavior, xx (dt : float64, recorder : *RecorderEntity) {
        if recorder.mode == .Idle {
            if Sill.input_action_just_activated(*game.engine.input, "recorder.record") {
                recorder.mode = .Recording;
                recorder.worldStates.count = 0;
                Chamber.debug("[Recorder] Currently recording. Press R to pause before replay.");
            }
        }
        else if recorder.mode == .Recording {
            if Sill.input_action_just_activated(*game.engine.input, "recorder.replay") {
                recorder.mode = .Pause;
                Chamber.debug("[Recorder] Currently pausing. Press R to replay.");
                return;
            }

            worldState := Basic.array_add(*recorder.worldStates);

            // @fixme Have "automatic" serialization, deserialization.
            worldState.player.transform = game.player.transform.transform;
        }
        else if recorder.mode == .Pause {
            if Sill.input_action_just_activated(*game.engine.input, "recorder.replay") {
                recorder.mode = .Replay;
                recorder.replayCurrentFrame = 0;
                Chamber.debug("[Recorder] Currently replaying.");
                return;
            }
        }
        else if recorder.mode == .Replay {
            worldState := *recorder.worldStates[recorder.replayCurrentFrame];
            Sill.transform_set(*game.playerClone.transform, worldState.player.transform);
            recorder.replayCurrentFrame += 1;

            if recorder.worldStates.count == recorder.replayCurrentFrame {
                recorder.mode = .Idle;
                Chamber.debug("[Recorder] Currently idle. End of replay. Press R to record.");
                return;
            }
        }

    }, recorder);
}
