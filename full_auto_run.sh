#!/usr/bin/env bash
set -euo pipefail

OUT_ROOT="output"
DATA_ROOT="/workspace/data"

DATA_PATHS=(
  "endonerf/cutting_tissues_twice"
  "stereomis/p2_1_1_247"
  "stereomis/p2_6_5000_200"
  "endonerf/pulling_soft_tissues"
  "stereomis/p3_9100_368"
  "stereomis/p3_11000_401" 
)
EXP_BASE=(
  "endonerf/cutting"
  "stereomis/p2_1_1_247"
  "stereomis/p2_6_5000_200"
  "endonerf/pulling"
  "stereomis/p3_9100_368"
  "stereomis/p3_11000_401"
)
CONFIGS=(
  "arguments/endonerf/default.py"
  "arguments/endonerf/default.py"
  "arguments/stereomis/default.py"
  "arguments/stereomis/default.py"
  "arguments/stereomis/default.py"
  "arguments/stereomis/default.py"
)

for i in "${!DATA_PATHS[@]}"; do
  data_path="${DATA_PATHS[$i]}"
  exp_base="${EXP_BASE[$i]}"
  data_name="${DATA_NAMES[$i]}"
  config="${CONFIGS[$i]}"

  echo "===== Processing dataset: $data_name ====="
  DATA_PATH="$DATA_ROOT/$data_path"
  EXP_BASE="$exp_base"
  DATA_NAME="$data_name"
  CONFIG="$config"

  OUT_DIR="${OUT_ROOT}/mean_eval_${EXP_NAME}"
  TARGET_DIR="${OUT_ROOT}/${EXP_NAME}"

  if [ -n "$TARGET_DIR" ] && [ "$TARGET_DIR" != "/" ]; then
      rm -rf "$TARGET_DIR"
  fi

  mkdir -p "$OUT_DIR"

  for i in $(seq -w $start_run 1); do

    RUN_OUT_DIR="${OUT_DIR}/run${i}"
    mkdir -p "$RUN_OUT_DIR"

    echo "===== Run $i: $EXP_NAME ====="

    python train.py -s "$DATA_PATH" --expname "$EXP_NAME" --configs "$CONFIG"
    python render.py --model_path "output/$EXP_NAME" --skip_train --skip_video --configs "$CONFIG"
    python metrics.py --model_path "output/$EXP_NAME" -p test

    cp "output/$EXP_NAME/per_view.json" "$RUN_OUT_DIR/per_view.json"
    cp "output/$EXP_NAME/results.json" "$RUN_OUT_DIR/results.json"
  done

  start_run=1

done