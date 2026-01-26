#!/bin/zsh
export PYTORCH_ALLOC_CONF=expandable_segments:True
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
# 1. 基本路徑與參數設定
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
FUNCTION_NAME="motionTransfer"
# 在這裡輸入你的 Prompt
RAW_PROMPT="A photorealistic koala wearing a McLaren Formula 1 team hat, ultra-high detail, 8K realism. The koala subtly reflects Oscar Piastri’s facial traits and presence: calm, focused expression, confident and composed eyes, youthful yet precise racing demeanor translated naturally into koala anatomy. Wet fur and skin with realistic moisture, water droplets and accurate subsurface scattering. The koala slowly eats fresh green grass with natural jaw and mouth movement. Cinematic soft daylight after rain, shallow depth of field, realistic shadows, motion-ready proportions, stable facial structure, no stylization."
INPUT_VIDEO="$BASE_DIR/data/motion_transfer/videos/1.mp4"

# 2. 自動生成「功能名 + Prompt + 時間」的資料夾名稱
SAFE_PROMPT=$(echo $RAW_PROMPT | tr ' ' '_' | tr -cd '[:alnum:]_')
TIMESTAMP=$(date +"%m%d_%H%M")
RUN_NAME="${FUNCTION_NAME}_${SAFE_PROMPT:0:20}_${TIMESTAMP}"
OUT_DIR="$BASE_DIR/outputs/$RUN_NAME"

# 建立專屬資料夾
mkdir -p "$OUT_DIR"
echo ">>> 實驗結果存於: $OUT_DIR"

# 3. 定義中間產物路徑 (確保三段流程讀取的路徑一致)
REPAINT_FILE="$OUT_DIR/temp_repainted.png"
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
python demo.py \
    --stage tracking \
    --repaint "$REPAINT_FILE" \
    --output_dir "$OUT_DIR" \
    --input_path "$INPUT_VIDEO" \
    --prompt "$RAW_PROMPT"

# --- STAGE 3: RENDER ---
echo "===== [3/3] STAGE: RENDER ====="
python demo.py \
    --stage render \
    --repaint "$REPAINT_FILE" \
    --tracking_path "$TRACKING_FILE" \
    --output_dir "$OUT_DIR" \
    --input_path "$INPUT_VIDEO" \
    --prompt "$RAW_PROMPT" \
    --num_inference_steps 20

echo "===== 任務完成！請查看: $OUT_DIR ====="