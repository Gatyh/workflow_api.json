# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
# (no custom registry nodes declared in the workflow)

# download PBRify models from Kim2091's GitHub repo
RUN wget -O /comfyui/models/upscale_models/4x-PBRify_UpscalerSPAN_Neutral.pth "https://github.com/Kim2091/PBRify_Remix/raw/main/Extras/Old_Models/4x-PBRify_UpscalerSPAN_Neutral.pth"
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_Height.pth "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_Height.pth"
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_NormalV3.pth "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_NormalV3.pth"
RUN wget -O /comfyui/models/upscale_models/1x-PBRify_RoughnessV2.pth "https://github.com/Kim2091/PBRify_Remix/raw/main/Models/1x-PBRify_RoughnessV2.pth"

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
