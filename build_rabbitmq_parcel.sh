parcel_version=$1
echo "Installing RabbitMQ and its dependencies..."
echo "Installing Erlang..."

YUMOPTS="-y -e1 -d1"

exit_code=1
retry_count=0
first_time=1

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
echo "Added Erlang repository."

while [ $exit_code == 1 ] && [ $retry_count -le 5 ]; do

	retry_count=$(($retry_count+1))
	if [[ $first_time == 1 ]]; then
		echo "Enter the version of Erlang you want to install. You can also enter list_versions to list all the available Erlang versions"
	else
		echo "Failed to install. Enter list_versions to list all the available Erlang versions or enter another version"
	fi

	first_time=0

	read erlang_version

	if [[ ${erlang_version} == "list_versions" ]]; then
		yum --showduplicates list erlang
		echo "Enter Erlang version: "
		read erlang_version
	fi

	yum $YUMOPTS install erlang-${erlang_version}.x86_64
	exit_code="$?"

done

if [[ $exit_code == 0 ]]; then
	echo "Successfully installed Erlang ${erlang_version}."
fi

exit_code=1
retry_count=0
first_time=1

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
echo "Added RabbitMQ repository."

while [ $exit_code == 1 ] && [ $retry_count -le 5 ]; do

	retry_count=$(($retry_count+1))
	if [[ $first_time == 1 ]]; then
		echo "Enter the version of RabbitMQ you want to install. You can also enter list_versions to list all the available RabbitMQ versions"
	else
		echo "Failed to install. Enter list_versions to list all the available RabbitMQ versions or enter another version"
	fi

	first_time=0

	read rabbitmq_version

	if [[ $rabbitmq_version == "list_versions" ]]; then
		yum --showduplicates list rabbitmq-server
		echo "Enter RabbitMQ version: "
		read rabbitmq_version
	fi

	yum $YUMOPTS install rabbitmq-server-${rabbitmq_version}.noarch
	exit_code="$?"

done

echo "Enabling RabbitMQ plugins..."
rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins enable rabbitmq_shovel


echo "Building the parcel..."
PARCEL_NAME=RABBITMQ-${parcel_version}-${rabbitmq_version}-${erlang_version}

cur_dir=`pwd`
mkdir $PARCEL_NAME

echo "Adding Erlang to the parcel..."
for i in `rpm -ql erlang`;
do
	DIR=$(dirname $i)
	mkdir -p ${cur_dir}/${PARCEL_NAME}/$DIR
	cp -rf $i ${cur_dir}/${PARCEL_NAME}$i
done

echo "Adding RabbitMQ to the parcel..."
for i in `rpm -ql rabbitmq-server`;
do
	DIR=$(dirname $i)
	mkdir -p ${cur_dir}/${PARCEL_NAME}/$DIR
	cp -rf $i ${cur_dir}/${PARCEL_NAME}$i
done

os_ver=`cat /etc/os-release | grep VERSION_ID`

if [[ $os_ver == 'VERSION_ID="7"' ]]; then 
	dist_suffix=el7; 
elif [[ $os_ver == 'VERSION_ID="6"' ]]; then 
	dist_suffix=el6; 
else 
	echo "Unsupported operating system"; 
fi

cp -rf meta ${PARCEL_NAME}/

sed -i "4s/.*/  \"version\": \"${parcel_version}-${rabbitmq_version}-${erlang_version}\",/" ${PARCEL_NAME}/meta/parcel.json
sed -i '21s+.*+ROOTDIR=${RABBITMQ_DIR}/usr/lib64/erlang+' ${PARCEL_NAME}/usr/lib64/erlang/bin/erl
sed -i '19s+.*+SYS_PREFIX=${RABBITMQ_DIR}+' ${PARCEL_NAME}/usr/lib/rabbitmq/lib/rabbitmq_server-3.7.9/sbin/rabbitmq-defaults
sed -i '22s+.*+ERL_DIR=${RABBITMQ_DIR}/usr/lib64/erlang/bin/+' ${PARCEL_NAME}/usr/lib/rabbitmq/lib/rabbitmq_server-3.7.9/sbin/rabbitmq-defaults

tar zcvf ${PARCEL_NAME}-${dist_suffix}.parcel ${PARCEL_NAME}

sha1sum ${PARCEL_NAME}-${dist_suffix}.parcel | awk '{ print $1 }' > ${PARCEL_NAME}-${dist_suffix}.parcel.sha
