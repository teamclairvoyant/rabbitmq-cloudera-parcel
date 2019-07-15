# RabbitMQ [Parcel](https://github.com/cloudera/cm_ext/wiki/Parcels:-What-and-Why%3F)

This repository allows you to install [RabbitMQ](https://www.rabbitmq.com/ as a parcel deployable by [Cloudera Manager](https://www.cloudera.com/products/product-components/cloudera-manager.html).

## Installing the Parcel
0. First, install the [RabbitMQ CSD](https://github.com/teamclairvoyant/rabbitmq-cloudera-csd).  Then you can skip steps #1 and #2.
1. In Cloudera Manager, go to `Hosts -> Parcels -> Configuration`.
2. Add `http://archive.clairvoyantsoft.com/rabbitmq/parcels/latest/` to the Remote Parcel Repository URLs if it does not yet exist.
3. In Cloudera Manager, go to `Hosts -> Parcels`.  RabbitMQ parcels and their respective verisons will be availble within the Parcels page.
4. Download, Distribute, Activate the required parcels to use them.

## Building the Parcel
1. Install [Docker](https://www.docker.com/) and [Python](https://www.python.org/).
2. Run the script `build_rabbitmq_parcel.sh` by executing:
```bash
./build_rabbitmq_parcel.sh --rabbitmq <rabbitmq_version> --erlang <erlang_version> --parcel <parcel_version>
```
RabbitMQ is only compatible with specific versions of Erlang.  See the [compatiblty list](https://www.rabbitmq.com/which-erlang.html) for details.
3. Output will be placed in the target/ directory.
4. Use `./serve_parcel.sh` to serve this directory via HTTP, or move the entire directory contents to your own webserver.

