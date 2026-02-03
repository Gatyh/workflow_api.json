# =============================================================================
# ComfyUI Docker - 3DTexel Full Stack
# =============================================================================
# Workflows disponibles:
#   - workflow_api_pbrify.json          : PBR via PBRify (sans seamless)
#   - workflow_api_pbrify_seamless.json : PBR via PBRify + Seamless
#   - workflow_api_mtb_seamless.json    : PBR via MTB Deep Bump + Seamless
#   - workflow_api_decal.json           : Decal generator (RGB + Alpha séparé)
#   - workflow_api_hymotion.json        : HY-Motion animation (GLB export)
#   - workflow_api_hdri360.json         : HunyuanWorld panorama 360 statique
# =============================================================================

FROM runpod/worker-comfyui:5.5.1-base

# -----------------------------------------------------------------------------
# SECTION 1: Custom Nodes existants (PBR & Decal) - NE PAS MODIFIER
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
# SECTION 2: PBRify Models - NE PAS MODIFIER
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
# SECTION 3: Deep Bump ONNX Model - NE PAS MODIFIER
# -----------------------------------------------------------------------------
RUN mkdir -p /comfyui/models/deepbump && \
    wget -O /comfyui/models/deepbump/deepbump256.onnx \
    "https://github.com/HugoTini/DeepBump/raw/master/deepbump256.onnx"

RUN mkdir -p /comfyui/custom_nodes/comfy_mtb/models && \
    cp /comfyui/models/deepbump/deepbump256.onnx /comfyui/custom_nodes/comfy_mtb/models/

RUN pip install onnxruntime-gpu

# =============================================================================
# SECTION 4: HY-Motion Animation (NOUVEAU)
# =============================================================================

# 4.1 ComfyUI-HY-Motion1 custom node
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Tencent/HY-Motion.git ComfyUI-HY-Motion1 && \
    cd ComfyUI-HY-Motion1 && \
    pip install -r requirements.txt

# 4.2 Dépendances supplémentaires pour HY-Motion
RUN pip install accelerate bitsandbytes torchdiffeq

# 4.3 Modèles HY-Motion (téléchargement depuis HuggingFace)
# HY-Motion-1.0 (modèle complet pour qualité maximale)
RUN mkdir -p /comfyui/models/HYMotion/ckpts && \
    cd /comfyui/models/HYMotion/ckpts && \
    huggingface-cli download tencent/HY-Motion-1.0 --local-dir HY-Motion-1.0

# Qwen3-8B LLM (pour génération de mouvement de haute qualité)
RUN cd /comfyui/models/HYMotion/ckpts && \
    huggingface-cli download Qwen/Qwen3-8B --local-dir Qwen3-8B

# Lien symbolique pour que le node trouve les modèles
RUN ln -sf /comfyui/models/HYMotion/ckpts /comfyui/custom_nodes/ComfyUI-HY-Motion1/ckpts

# =============================================================================
# SECTION 5: HunyuanWorld Panorama 360 (NOUVEAU)
# =============================================================================

# 5.1 Dépendances pour HunyuanWorld panorama generation
RUN pip install diffusers transformers safetensors

# 5.2 FLUX.1-dev base model (requis pour panorama 360)
# Note: ~24GB, nécessite GPU avec 24GB+ VRAM
RUN mkdir -p /comfyui/models/diffusers && \
    huggingface-cli download black-forest-labs/FLUX.1-dev \
    --local-dir /comfyui/models/diffusers/FLUX.1-dev

# 5.3 HunyuanWorld PanoDiT LoRA models
RUN mkdir -p /comfyui/models/HunyuanWorld && \
    huggingface-cli download tencent/HunyuanWorld-1 \
    --include "HunyuanWorld-PanoDiT-Text/*" \
    --local-dir /comfyui/models/HunyuanWorld

RUN huggingface-cli download tencent/HunyuanWorld-1 \
    --include "HunyuanWorld-PanoDiT-Image/*" \
    --local-dir /comfyui/models/HunyuanWorld

# 5.4 Script standalone pour génération panorama 360
# (pas de node ComfyUI officiel, utilise le script Python directement)
RUN cd /comfyui && \
    git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-1.0.git

# =============================================================================
# SECTION 6: Configuration finale
# =============================================================================

# Variables d'environnement pour optimisation mémoire
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
ENV TRANSFORMERS_CACHE=/comfyui/models/cache
ENV HF_HOME=/comfyui/models/cache

# Créer dossiers de cache
RUN mkdir -p /comfyui/models/cache

# -----------------------------------------------------------------------------
# Notes d'utilisation:
# -----------------------------------------------------------------------------
# HY-Motion:
#   - Utiliser workflow_api_hymotion.json
#   - Input: prompt texte décrivant le mouvement
#   - Output: fichier GLB avec animation
#   - GPU requis: 24GB+ VRAM pour qualité maximale
#
# HunyuanWorld Panorama 360:
#   - Utiliser le script: python /comfyui/HunyuanWorld-1.0/demo_panogen.py
#   - Input: --prompt "description de la scène"
#   - Output: panorama.png (1920x960 équirectangulaire)
#   - GPU requis: 24GB+ VRAM (FLUX.1-dev)
#   - Options: --fp8_gemm --fp8_attention pour réduire VRAM (~16GB)
# =============================================================================
