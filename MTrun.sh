# -*- coding: utf-8 -*-
# +
#!/bin/zsh
export PYTORCH_ALLOC_CONF=expandable_segments:True

# 1. 基本路徑與參數設定
BASE_DIR="/mnt/cglab/uuuu/DaS"
FUNCTION_NAME="motionTransfer"
# 在這裡輸入你的 Prompt
RAW_PROMPT="A realistic sea lion with wet skin eating grass"
INPUT_VIDEO="$BASE_DIR/data/motion_transfer/videos/1.mp4"

# 2. 自動生成「功能名 + Prompt + 時間」的資料夾名稱
# 將 Prompt 中的空格換成底線，並過濾掉特殊字元，避免路徑出錯
SAFE_PROMPT=$(echo $RAW_PROMPT | tr ' ' '_' | tr -cd '[:alnum:]_')
TIMESTAMP=$(date +"%m%d_%H%M")
RUN_NAME="${FUNCTION_NAME}_${SAFE_PROMPT:0:50}_${TIMESTAMP}" # 限制長度防止檔名太長
OUT_DIR="$BASE_DIR/outputs/$RUN_NAME"

# 建立專屬資料夾
mkdir -p "$OUT_DIR"
echo ">>> 本次實驗結果將儲存於: $OUT_DIR"

# 3. 定義中間產物路徑 (確保三段流程讀取的路徑一致)
REPAINT_FILE="$OUT_DIR/repaint_0.jpg"
TRACKING_FILE="$OUT_DIR/tracking_video.mp4"

# --- STAGE 1: REPAINT ---
echo "===== [1/3] STAGE: REPAINT ====="
python demo.py \
    --stage repaint \
    --repaint true \
    --output_dir "$OUT_DIR" \
    --input_path "$INPUT_VIDEO" \
    --prompt "$RAW_PROMPT"

# --- STAGE 2: TRACKING ---
echo "===== [2/3] STAGE: TRACKING ====="
# 注意：這裡 --repaint 傳入的是 Stage 1 生成的絕對路徑
python demo.py \
    --stage tracking \
    --repaint "$REPAINT_FILE" \
    --output_dir "$OUT_DIR" \
    --input_path "$INPUT_VIDEO" \
    --prompt "$RAW_PROMPT"

# --- STAGE 3: RENDER ---
echo "===== [3/3] STAGE: RENDER ====="
# 注意：這裡 --repaint 和 --tracking_path 都傳入絕對路徑
python demo.py \
    --stage render \
    --repaint "$REPAINT_FILE" \
    --tracking_path "$TRACKING_FILE" \
    --output_dir "$OUT_DIR" \
    --input_path "$INPUT_VIDEO" \
    --prompt "$RAW_PROMPT" \
    --num_inference_steps 20

echo "===== 任務完成！結果請查看: $OUT_DIR ====="
