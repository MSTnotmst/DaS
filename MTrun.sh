# -*- coding: utf-8 -*-
# +
#!/bin/zsh

# 1. 設定環境變數與路徑
export PYTORCH_ALLOC_CONF=expandable_segments:True
OUTPUT_DIR="./outputs/motionTransfer"

# 參數設定
PROMPT="A realistic sea lion with wet skin, sitting on a green lawn, eating grass, cinematic lighting"
INPUT_PATH="./data/motion_transfer/videos/1.mp4"
CHECKPOINT="./checkpoints/Diffusion-As-Shader"


# --- 第一部分：重繪 (Repaint Only) ---
echo "===== Stage 1: Repainting First Frame ====="
python demo.py \
    --prompt "$PROMPT" \
    --input_path "$INPUT_PATH" \
    --checkpoint_path "$CHECKPOINT" \
    --output_dir "$OUTPUT_DIR" \
    --repaint true \
    --only_repaint \
    --gpu 0

# --- 第二部分：生成影片 (Video Generation) ---
# 注意：這裡我們假設重繪後的圖片叫做 repaint_0.jpg (請根據實際輸出的檔名修改)
REPAINTED_IMAGE="$OUTPUT_DIR/repaint_0.jpg"

echo "===== Stage 2: Generating Video using $REPAINTED_IMAGE ====="
python demo.py \
    --prompt "$PROMPT" \
    --input_path "$INPUT_PATH" \
    --checkpoint_path "$CHECKPOINT" \
    --output_dir "$OUTPUT_DIR" \
    --repaint "$REPAINTED_IMAGE" \
    --num_inference_steps 20 \
    --gpu 0

echo "===== All Stages Finished! ====="
