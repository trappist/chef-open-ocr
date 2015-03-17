#
# Cookbook Name:: open-ocr
# Recipe:: default
#
# Copyright 2015, Rocco Stanzione
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
#

%w[golang git].each do |pkg|
  package pkg do
    action :install
  end
end

gopath = '/opt/go'

directory gopath do
  action :create
end

bash "build_open_ocr" do
  cwd gopath
  code <<-EOH
    go get -u -v -t github.com/tleyden/open-ocr
    cd #{gopath}/src/github.com/tleyden/open-ocr/cli-httpd
    go build -v -o open-ocr-httpd
    cp open-ocr-httpd /usr/bin
    cd #{gopath}/src/github.com/tleyden/open-ocr/cli-worker
    go build -v -o open-ocr-worker
    cp open-ocr-worker /usr/bin
  EOH
end

bash "start_open_ocr" do
  code <<-EOH
    export HTTP_PORT=8080
    export AMQP_URI="amqp://guest:guest@localhost/"
    open-ocr-worker -amqp_uri "${AMQP_URI}"
    open-ocr-httpd -amqp_uri "${AMQP_URI}" -http_port ${HTTP_PORT}
  EOH
end
