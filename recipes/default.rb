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

package 'rabbitmq-server'
package 'golang'
package 'git'
package 'tesseract-ocr'

gopath = '/opt/go'
amqp_uri = "amqp://guest:guest@localhost/"

ENV['GOPATH'] = gopath

directory gopath do
  action :create
end

execute "build_open_ocr" do
  cwd gopath
  creates "#{gopath}/src/github.com/tleyden/open-ocr/cli-httpd"
  command <<-EOH
    go get -u -v -t github.com/tleyden/open-ocr
    cd #{gopath}/src/github.com/tleyden/open-ocr/cli-httpd
    go build -v -o open-ocr-httpd
    cp open-ocr-httpd /usr/bin
    cd #{gopath}/src/github.com/tleyden/open-ocr/cli-worker
    go build -v -o open-ocr-worker
    cp open-ocr-worker /usr/bin
  EOH
end

%w[worker httpd].each do |process|

  template "/etc/init/open-ocr-#{process}.conf" do
    mode "0644"
    source "init/open-ocr-#{process}.conf"
  end

  execute "start_open_ocr_#{process}" do
    command "start open-ocr-#{process}"
  end

end
