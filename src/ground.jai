GroundEntity :: struct {
    using entity : Sill.Entity;
    transform : Sill.TransformComponent;
    mesh : Sill.MeshComponent;
}

ground_init :: () {
    ground := SillMeta.create_ground_entity(game.engine);

    Sill.mesh_make_plane(*ground.mesh, extent = .{20, 20});
}
