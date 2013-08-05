#
# Cookbook Name:: kafka
# Attributes:: default
#
# Copyright 2012, Webtrends, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install
default[:kafka][:kafka_version] = "kafka_2.8.0-0.8.0-beta1"
default[:kafka][:download_url] = "https://dist.apache.org/repos/dist/release/kafka" 
default[:kafka][:checksum] = "750046ab729d"

default[:kafka][:install_dir] = "/mnt/kafka"
default[:kafka][:data_dir] = "/mnt/kafka/data"
default[:kafka][:log_dir] = "/mnt/kafka/log"
default[:kafka][:chroot_suffix] = "brokers"

default[:kafka][:num_partitions] = 1
default[:kafka][:broker_id] = nil
default[:kafka][:broker_host_name] = nil
default[:kafka][:port] = 9092
default[:kafka][:threads] = nil
default[:kafka][:log_flush_interval] = 10000
default[:kafka][:log_flush_time_interval] = 1000
default[:kafka][:log_flush_scheduler_time_interval] = 1000
default[:kafka][:log_retention_hours] = 168
default[:kafka][:zk_connectiontimeout] = 10000

default[:kafka][:user] = "kafka"
default[:kafka][:group] = "kafka"

default[:kafka][:log4j_logging_level] = "INFO"
