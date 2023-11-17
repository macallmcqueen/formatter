# Ignoring these pylint warnings:
# C0302: too many lines in module
# C0330: wrong hanging indent
#     - pylint doesn't like black's formatting style
# R0902: too many instance attributes
# R0903: too few public methods in class
# R0904: too many public methods in class
# R0913: too many arguments
# W0703: catching too general exception
# C0413: used when code and imports are mixed
# W0707: 'raise' missing 'from'
# W1514: Using open without explicitly specifying an encoding
PYLINT_IGNORE_CODES='C0302,C0330,R0902,R0903,R0904,R0913,W0703,C0413,W0707,W1514,R0201'
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
  /home/mmcqueen/.local/bin/ssort $1 2>&1
  error_count=$((error_count + $?))
fi

if $all
then
  echo "${BAR}pre-formatting..."
  /home/mmcqueen/.local/bin/ruff format --preview --config $CONFIG_FILE_PATH $1 2>&1
  error_count=$((error_count + $?))
fi

if $all
then
  echo "${BAR}linting & fixing..."
  /home/mmcqueen/.local/bin/ruff check --fix --unsafe-fixes --preview --config $CONFIG_FILE_PATH $1 2>&1
  error_count=$((error_count + $?))
fi

echo "${BAR}formatting..."
/home/mmcqueen/.local/bin/ruff format --preview --config $CONFIG_FILE_PATH $1 2>&1
/usr/bin/sed "s/\"\"\"/'''/g" -i $1 2>&1  # changes ''' back to '''
error_count=$((error_count + $?))

if $all
then
  echo "${BAR}checking docstrings..."
  /home/mmcqueen/.local/bin/pydoclint --config $CONFIG_FILE_PATH $1 # 2>&1
  error_count=$((error_count + $?))
fi


if $all
then
  echo "${BAR}checking type hints..."
  /home/mmcqueen/.local/bin/mypy --install-types --non-interactive --ignore-missing-imports --disallow-untyped-defs --disable-error-code union-attr $1 2>&1
  error_count=$((error_count + $?))
fi

if $all
then
  echo "${BAR}pylint..."
  /home/mmcqueen/vicevenv/bin/pylint $1 --rcfile $CONFIG_FILE_PATH 2>&1
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
