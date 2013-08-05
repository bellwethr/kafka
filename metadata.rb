maintainer        "Webtrends, Inc."
maintainer_email  "ivan.vonnagy@webtrends.com"
license           "Apache 2.0"
description       "Intalls and configures a Kafka broker"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.20"

depends           "java"

recipe	"kafka::default",		"Base configuration for kafka"

supports "ubuntu"
