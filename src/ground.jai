GroundEntity :: struct {
    using entity : Sill.Entity;
    transform : Sill.TransformComponent;
    mesh : Sill.MeshComponent;
}

ground_init :: () {
    ground := SillMeta.create_ground_entity(game.engine);

    // @note Can't have a ground being a plane with ray-tracing,
    // otherwise it's bounding box is almost null in one direction if axis-aligned,
    // and things go wrong.
    Sill.mesh_make_cube(*ground.mesh, extent = .{20, 20, 1});
}
