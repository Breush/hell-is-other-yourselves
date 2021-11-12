#version 450

// Tweak the player vision to let him know he's detected by its clone.

// ------------------
// ----- VERTEX -----

#if defined(VERTEX)

#include "$/post-process-renderer/default.vert"

// --------------------
// ----- FRAGMENT -----

#elif defined(FRAGMENT)

#include "$/post-process-renderer/default-header.frag"

layout(std140, set = MATERIAL_DESCRIPTOR_SET_INDEX, binding = 0) uniform MaterialShaderObject {
    float power;
} material;

void main() {
    vec4 sourceColor = texture(source, uv);

    float uvLength = length(uv - 0.5);
    outColor = mix(sourceColor, vec4(1, 0, 0, 1), material.power * uvLength);
}

#endif
