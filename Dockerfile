# 3DTexel ComfyUI Workflows

Repository contenant les workflows ComfyUI pour la génération PBR et Decal sur RunPod Serverless.

## Workflows Disponibles

| Workflow | Description | Custom Nodes | Output |
|----------|-------------|--------------|--------|
| `workflow_api_pbrify.json` | PBR via PBRify (production actuelle) | - | Albedo, Height, Normal, Roughness, Metallic |
| `workflow_api_pbrify_seamless.json` | PBR via PBRify + Seamless | MakeSeamlessTexture | Albedo, Height, Normal, Roughness, Metallic |
| `workflow_api_mtb_seamless.json` | PBR via MTB Deep Bump + Seamless | MakeSeamlessTexture, comfy_mtb | Albedo, Height, Normal, Roughness |
| `workflow_api_decal.json` | Decal Generator | comfy_mtb | Albedo, Opacity, Normal, Height, Roughness |

## Architecture des Workflows

### PBRify (Standard)
```
LoadImage → 4x Upscale (PBRify) → Save Albedo
                               → 1x Height (PBRify) → Save Height
                               → 1x Normal (PBRify) → Save Normal
                               → 1x Roughness (PBRify) → Save Roughness
                               → Metallic Generator → Save Metallic
```

### PBRify + Seamless
```
LoadImage → SeamlessTextureRadialMask → 4x Upscale (PBRify) → [même que ci-dessus]
```

### MTB + Seamless
```
LoadImage → SeamlessTextureRadialMask → 4x Upscale (PBRify) → Save Albedo
                                                            → Deep Bump (Color to Normals) → Save Normal
                                                                                           → Deep Bump (Normals to Height) → Save Height
                                                            → 1x Roughness (PBRify) → Save Roughness
```

### Decal Generator
```
LoadImage (RGBA) → 4x Upscale RGB (PBRify) → Save Albedo
                                           → Deep Bump (Normal) → Save Normal
                                                                → Deep Bump (Height) → Save Height
                                           → 1x Roughness (PBRify) → Save Roughness
                → Extract Alpha → Upscale Alpha → Save Opacity
```

## Custom Nodes Requis

- **ComfyUI-MakeSeamlessTexture** - Pour les workflows seamless
- **comfy_mtb** - Pour Deep Bump (Normal/Height de haute qualité)

## Modèles Requis

### PBRify Models
- `4x-PBRify_UpscalerSPAN_Neutral.pth` - Upscale 4x
- `1x-PBRify_Height.pth` - Génération Height
- `1x-PBRify_NormalV3.pth` - Génération Normal
- `1x-PBRify_RoughnessV2.pth` - Génération Roughness

### Deep Bump Model
- `deepbump256.onnx` - Pour MTB Deep Bump

## Déploiement RunPod

```bash
# Build Docker
docker build -t 3dtexel-comfyui .

# Push vers registry
docker tag 3dtexel-comfyui your-registry/3dtexel-comfyui:latest
docker push your-registry/3dtexel-comfyui:latest
```

## API Usage

Envoyer le workflow via l'API RunPod avec l'image en base64:

```json
{
  "input": {
    "workflow": "<workflow_json>",
    "images": [
      {
        "name": "input_texture.png",
        "image": "<base64_encoded_image>"
      }
    ]
  }
}
```

## Changelog

- **v2.0** - Ajout workflows Seamless + Decal Generator
- **v1.0** - Workflow PBRify initial
