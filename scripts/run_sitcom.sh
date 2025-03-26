Xvfb :1 -screen 0 1024x768x24 &
export DISPLAY=:1
model_name=sitcom
tasks=(
  bridge.sh
)
ckpts=(
  openvla/openvla-7b
)
unnorm_key=simpler_rlds

action_ensemble_temp=-0.8
for ckpt_path in ${ckpts[@]}; do
  base_dir=$(dirname $ckpt_path)

  # evaluation in simulator
  # logging_dir=$base_dir/simpler_env/$(basename $ckpt_path)${action_ensemble_temp}
  logging_dir=results/$(basename $ckpt_path)${action_ensemble_temp}
  mkdir -p $logging_dir
  for i in ${!tasks[@]}; do
    task=${tasks[$i]}
    echo "🚀 running $task ..."
    device=0,1,2,3,4,5,6,7
    session_name=CUDA${device}-$(basename $logging_dir)-${task}
    bash scripts/$task $ckpt_path $model_name $action_ensemble_temp $logging_dir $device $unnorm_key
  done

  # statistics evalution results
  echo "🚀 all tasks DONE! Calculating metrics..."
  python tools/calc_metrics_evaluation_videos.py \
    --log-dir-root $logging_dir \
    >>$logging_dir/total.metrics
done
