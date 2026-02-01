# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui
# Install comfy_mtb (Deep Bump) for high-quality normal and height map generation
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/melMass/comfy_mtb.git && \
    cd comfy_mtb && \
    pip install -r requirements.txt

# download PBRify models (4x upscaler and roughness generator)
RUN wget -O /comfyui/models/upscale_models/4x-PBRify_UpscalerSPAN_Neutral.pth "https://huggingface.co/easygoing0114/AI_upscalers/resolve/main/4x-PBRify_RPLKSRd_V3.pth"
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_RoughnessV2.pth "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_RoughnessV2.pth"

# Deep Bump models will be downloaded automatically on first use

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
