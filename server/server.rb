#!/usr/bin/ruby

# This file is part of Shortest-Path-Server.

# Copyright (c) 2014 Evan Berry 

# Shortest-Path-Server is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or (at your option) any later version.

# Shortest-Path-Server is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR 
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with 
# Shortest-Path-Server. If not, see http://www.gnu.org/licenses/.
require './parser.rb'
require './mapper_objects.rb'
require 'socket'

ERROR_MESSAGE = "INVALID INPUT"
def create_nodes edges 
  nodes = {}
  edges.each do |e|
    unless nodes[e.source]
      nodes[e.source] = Node.new(e.source)
    end
    unless nodes[e.dest]
      nodes[e.dest] = Node.new(e.dest)
    end
    nodes[e.source].add_link(e.dest, e.cost)
  end
  nodes
end

server = TCPServer.new(7777)

loop do 
  connection = server.accept
  begin 
    parser = Parser.new 
    parser.read connection
    nodes = create_nodes parser.edges
    checks = preliminary_checks(parser.entry, parser.terminal, nodes)
    if checks
      result = Explore.new(parser.entry, parser.terminal, nodes)
    else 
      result = ERROR_MESSAGE
    end
    connection.puts result.path
  rescue 
    connection.puts ERROR_MESSAGE
  end
  connection.close 
end
