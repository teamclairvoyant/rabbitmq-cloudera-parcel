## Building a parcel

1. Clone the repo using
    ```bash
    git clone https://github.com/teamclairvoyant/rabbitmq-cloudera-parcel.git
    ```
2. Execute build_rabbitmq_parcel.sh using
    ```bash
    sh build_rabbitmq_parcel.sh <parcel_version>
    ```
3. Enter the Erlang and RabbitMQ versions when asked. You can enter `list_versions` to get a list of all the available versions. A `.parcel` and a `.sha` file will be generated. 
4. Copy all your the files in the repository into a directory and generate manifest.json file using
    ```bash
    python make_manifest.py <Directory>
    ```
5. Upload the newly created parcel and the updated manifest.json into the repository.
