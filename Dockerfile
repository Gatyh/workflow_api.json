# =============================================================================
# ComfyUI Docker - 3DTexel PBR & Decal Generator
# =============================================================================
# Workflows disponibles:
#   - workflow_api_pbrify.json          : PBR via PBRify (sans seamless)
#   - workflow_api_pbrify_seamless.json : PBR via PBRify + Seamless
#   - workflow_api_mtb_seamless.json    : PBR via MTB Deep Bump + Seamless
#   - workflow_api_decal.json           : Decal generator (RGB + Alpha séparé)
# =============================================================================

FROM runpod/worker-comfyui:5.5.1-base

# -----------------------------------------------------------------------------
# Custom Nodes Installation
# -----------------------------------------------------------------------------

# 1. ComfyUI-MakeSeamlessTexture - Pour la génération de textures seamless
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/SparknightLLC/ComfyUI-MakeSeamlessTexture.git

# 2. comfy_mtb - Pour Deep Bump (Normal/Height generation de haute qualité)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/melMass/comfy_mtb.git && \
    cd comfy_mtb && \
    pip install -r requirements.txt

# -----------------------------------------------------------------------------
# PBRify Models - Pour upscale et génération PBR
# -----------------------------------------------------------------------------

# 4x Upscaler
RUN wget -O /comfyui/models/upscale_models/4x-PBRify_UpscalerSPAN_Neutral.pth \
    "https://huggingface.co/easygoing0114/AI_upscalers/resolve/main/4x-PBRify_RPLKSRd_V3.pth"

# PBR Map Generators (1x models)
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_Height.pth \
    "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_Height.pth"
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_NormalV3.pth \
    "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_NormalV3.pth"
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_RoughnessV2.pth \
    "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_RoughnessV2.pth"

# -----------------------------------------------------------------------------
# Deep Bump ONNX Model - Requis pour MTB workflows
# -----------------------------------------------------------------------------
RUN mkdir -p /comfyui/models/deepbump && \
    wget -O /comfyui/models/deepbump/deepbump256.onnx \
    "https://github.com/HugoTini/DeepBump/raw/master/deepbump256.onnx"

# -----------------------------------------------------------------------------
# Copy workflows (optional - can also be sent via API)
# -----------------------------------------------------------------------------
# COPY workflows/ /comfyui/workflows/
# COPY input/ /comfyui/input/
