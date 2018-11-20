## Building a parcel

1. Clone the repo using
    ```bash
    git clone https://github.com/teamclairvoyant/rabbitmq-cloudera-parcel.git
    ```
2. Execute build_rabbitmq_parcel.sh using
    ```bash
    sh build_rabbitmq_parcel.sh <parcel_version>
    ```
3. Enter the Erlang and RabbitMQ versions when asked. You can enter `list_versions` to get a list of all the available versions. You can find the compatible versions of Erlang and RabbtiMQ `https://www.rabbitmq.com/which-erlang.html`. A `.parcel` and a `.sha` file will be generated. 
4. Copy all your the files in the repository into a directory and generate manifest.json file using
    ```bash
    python make_manifest.py <Directory>
    ```
5. Upload the newly created parcel and the updated manifest.json into the repository.


## Installing the Parcels
1. In the Cloudera Manager, go to `Hosts -> Parcels -> Configurations`.
2. Add `http://teamclairvoyant.s3-website-us-west-2.amazonaws.com/apache-airflow/cloudera/parcels/` to the Remote Parcel Repository URLs.
3. Rabbit parcel and its respective verisons will be availble within the parcels page. 
4. Download, Distribute, Activate the required parcels to use them. 
