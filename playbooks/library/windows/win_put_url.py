#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2015, David O'Brien <david.obrien@versent.com.au>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

DOCUMENTATION = '''
---
module: win_put_url
version_added: "0.1"
short_description: Uploads a file to a URL 
description:
options:
	src: 
		description:
			- Specifies the full path to the file that is supposed to be uploaded.
		required: true
		default: null
		aliases: []
	dest:
		description:
			- Specifies the full http(s) URL to the location the file specified with src is supposed to be uploaded.
		required: true
		default: null
		aliases: []
	user_name:
		description:
			- Specifies the user's name used to authenticate against the web server
		required: false
		default: null
		aliases: []
	user_pwd:
		description:
			- Specifies the user's password (in clear text) to authenticate against the web server. This parameter is mandatory if you are also using user_name.
		required: false
		default: null
		aliases: []
		
EXAMPLES = '''
# Upload a file without authentication
- win_put_url: dest = http://$servername/$repository/filename.zip src=C:/windows/temp/backup.zip

# Upload a file with user and password authentication
- win_put_url: dest = http://$servername/$repository/filename.zip src=C:/windows/temp/backup.zip user_name=davidobrien user_pwd=VeRyStRoNgP@sSwOrD
