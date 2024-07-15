BAR="--------------------------------------------------------------------\n"
CONFIG_FILE_PATH='/home/mmcqueen/formatter/pyproject.toml'

error_count=0

# Use the -a flag to do everything; Without the -a flag, we only change the formatting
# and we don't reorder the imports or methods and don't run the linter.
all='false'
while getopts a flag; do
  case $flag in
    a) all='true';
      shift ;;
  esac
done

if $all
then
  echo "${BAR}sorting methods..."
  /home/mmcqueen/code/bin/ssort $1 2>&1
  error_count=$((error_count + $?))
fi

if $all
then
  echo "${BAR}pre-formatting..."
  /home/mmcqueen/code/bin/ruff format --preview --config $CONFIG_FILE_PATH $1 2>&1
  error_count=$((error_count + $?))
fi

if $all
then
  echo "${BAR}linting & fixing..."
  /home/mmcqueen/code/bin/ruff check --fix --unsafe-fixes --preview --config $CONFIG_FILE_PATH $1 2>&1
  error_count=$((error_count + $?))
fi

echo "${BAR}formatting..."
/home/mmcqueen/code/bin/ruff format --preview --config $CONFIG_FILE_PATH $1 2>&1
/usr/bin/sed "s/\"\"\"/'''/g" -i $1 2>&1  # changes ''' back to '''
error_count=$((error_count + $?))

if $all
then
  echo "${BAR}checking docstrings..."
  /home/mmcqueen/code/bin/pydoclint --config $CONFIG_FILE_PATH $1 # 2>&1
  error_count=$((error_count + $?))
fi


if $all
then
  echo "${BAR}checking type hints..."
  /home/mmcqueen/code/bin/mypy --install-types --non-interactive --ignore-missing-imports --disallow-untyped-defs --follow-imports=silent --disable-error-code union-attr --disable-error-code var-annotated $1 2>&1
  error_count=$((error_count + $?))
fi

if $all
then
  echo "${BAR}pylint..."
  /home/mmcqueen/code/bin/pylint $1 --rcfile $CONFIG_FILE_PATH --init-hook 'import sys; sys.path.append("/home/mmcqueen/git/vice_hub/roles/ocsp2/cf/files")' 2>&1
  error_count=$((error_count + $?))
fi

echo "${BAR}"
if [ $error_count -gt 0 ]
then
  echo "FAILED"
  exit 1
else
  echo "SUCCESS"
fi
