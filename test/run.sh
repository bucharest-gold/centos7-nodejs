#!/bin/bash
#
# IMAGE_NAME specifies a name of the candidate image used for testing.
# The image has to be available before this script is executed.
#
IMAGE_NAME=${IMAGE_NAME}
NODE_VERSION=${NODE_VERSION}

APP_IMAGE="$(echo ${IMAGE_NAME} | cut -f 1 -d':')-testapp"

test_dir=`dirname ${BASH_SOURCE[0]}`
image_dir="${test_dir}/.."
cid_file=`date +%s`$$.cid
test_port=8080

test_image_exists() {
  docker inspect $1 &>/dev/null
}

test_container_exists() {
  test_image_exists $(cat $cid_file)
}

test_docker_build() {
  docker build --pull=false -t ${APP_IMAGE} ${test_dir}/test-app
}

run_test_application() {
  echo "Starting test application ${APP_IMAGE}..."
  docker run --rm --cidfile=${cid_file} -p ${test_port}:${test_port} ${APP_IMAGE} &
  wait_for_cid
}

cleanup() {
  if [ -f $cid_file ]; then
    if test_container_exists; then
      docker stop $(cat $cid_file)
    fi
  fi
  if test_image_exists ${APP_IMAGE}; then
    docker rmi -f ${APP_IMAGE}
  fi
  cids=`ls -1 *.cid 2>/dev/null | wc -l`
  if [ $cids != 0 ]
  then
    rm *.cid
  fi
}

check_result() {
  local result="$1"
  if [[ "$result" != "0" ]]; then
    echo "'${IMAGE_NAME}' test FAILED (exit code: ${result})"
    exit $result
  fi
}

wait_for_cid() {
  local max_attempts=10
  local sleep_time=1
  local attempt=1
  local result=1
  while [ $attempt -le $max_attempts ]; do
    [ -f $cid_file ] && [ -s $cid_file ] && break
    echo "Waiting for container start..."
    attempt=$(( $attempt + 1 ))
    sleep $sleep_time
  done
}

test_node_version() {
  local run_cmd="node --version"
  local expected="v${NODE_VERSION}"

  echo "Checking nodejs runtime version ..."
  out=$(docker run --rm ${IMAGE_NAME} /bin/bash -c "${run_cmd}")
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[/bin/bash -c "${run_cmd}"] Expected '${expected}', got '${out}'"
    return 1
  fi
}

# Sets and Gets the NODE_ENV environment variable from the container.
get_set_node_env_from_container() {
  local node_env="$1"
  echo $(docker run --rm --env NODE_ENV=$node_env $IMAGE_NAME /bin/bash -c 'echo "$NODE_ENV"')
}

# Gets the NODE_ENV environment variable from the container.
get_default_node_env_from_container() {
  echo $(docker run --rm $IMAGE_NAME /bin/bash -c 'echo "$NODE_ENV"')
}

test_node_env_and_environment_variables() {
  local default_node_env="production"
  local node_env_prod="production"
  local node_env_dev="development"
  echo 'Validating default NODE_ENV, verifying ability to configure using Env Vars...'

  result=0

  if [ "$default_node_env" != $(get_default_node_env_from_container) ]; then
    echo "ERROR default NODE_ENV should be '$default_node_env'"
    result=1
  fi

  if [ "$node_env_prod" != $(get_set_node_env_from_container "$node_env_prod") ]; then
    echo "ERROR: NODE_ENV was unsuccessfully set to '$node_env_prod' mode"
    result=1
  fi

  if [ "$node_env_dev" != $(get_set_node_env_from_container "$node_env_dev") ]; then
    echo "ERROR: NODE_ENV unsuccessfully set to '$node_env_dev' mode"
    result=1
  fi

  return $result
}

test_connection() {
  run_test_application
  echo "Testing HTTP connection..."
  local max_attempts=10
  local sleep_time=1
  local attempt=1
  local result=1
  while [ $attempt -le $max_attempts ]; do
    echo "Sending GET request to http://localhost:${test_port}/"
    response_code=$(curl -s -w %{http_code} -o /dev/null http://localhost:${test_port}/)
    status=$?
    if [ $status -eq 0 ]; then
      if [ $response_code -eq 200 ]; then
        result=0
      fi
      break
    fi
    attempt=$(( $attempt + 1 ))
    sleep $sleep_time
  done
  return $result
}

test_image_exists ${IMAGE_NAME}
check_result $?

test_node_version
check_result $?

test_node_env_and_environment_variables
check_result $?

test_docker_build
check_result $?

test_image_exists ${APP_IMAGE}
check_result $?

test_connection
check_result $?

cleanup
echo "Success!"
