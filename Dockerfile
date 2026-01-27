# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
# (no custom registry nodes declared in the workflow)

# download models into comfyui
# RUN # Could not find URL for 4x-PBRify_UpscalerSPAN_Neutral.pth
# RUN # Could not find URL for 1x-PBRify_Height.pth
# RUN # Could not find URL for 1x-PBRify_NormalV3.pth
# RUN # Could not find URL for 1x-PBRify_RoughnessV2.pth

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
