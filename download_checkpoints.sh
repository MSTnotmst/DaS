pkill -9 -f python
sync



export HF_ENDPOINT=https://hf-mirror.com
CKPT_DIR="./checkpoints/Diffusion-As-Shader"


mkdir -p $CKPT_DIR/vae $CKPT_DIR/text_encoder $CKPT_DIR/transformer $CKPT_DIR/scheduler $CKPT_DIR/tokenizer

echo ">>> 開始強制下載 (共約 25GB)..."

huggingface-cli download THUDM/CogVideoX-5b vae/diffusion_pytorch_model.safetensors --local-dir $CKPT_DIR --local-dir-use-symlinks False
huggingface-cli download THUDM/CogVideoX-5b text_encoder/model.safetensors --local-dir $CKPT_DIR --local-dir-use-symlinks False
huggingface-cli download THUDM/CogVideoX-5b transformer/diffusion_pytorch_model.safetensors --local-dir $CKPT_DIR --local-dir-use-symlinks False

huggingface-cli download THUDM/CogVideoX-5b scheduler/scheduler_config.json tokenizer/tokenizer_config.json tokenizer/special_tokens_map.json tokenizer/spiece.model --local-dir $CKPT_DIR --local-dir-use-symlinks False



echo ">>> 下載完成！正在驗證檔案大小..."

ls -lh $CKPT_DIR/text_encoder/model.safetensors $CKPT_DIR/transformer/diffusion_pytorch_model.safetensors