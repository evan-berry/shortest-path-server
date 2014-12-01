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

# responsible for parsing out the entry,
# terminal, and edges
class Parser
  attr_reader :entry,
              :terminal

  attr_accessor :edge_count,
                :remainder,
                :edges

  class Edge
    attr_reader :source,
                :dest,
                :cost
    def initialize source, dest, cost
      @source = source
      @dest = dest
      @cost = cost
    end
   
  end

  def initialize
    @entry = nil
    @terminal = nil
    @edge_count = nil
    @remainder = nil
    @edges = []
  end

  def read connection
    string =  connection.read.force_encoding("BINARY")
    @entry       = string[0..1].unpack('S').first.to_s
    @terminal    = string[2..3].unpack('S').first.to_s
    @edge_count = string[4..5].unpack('S').first.to_i
    @remainder   = string[6..-1]
    map_edge_definitions
  end
 
  def map_edge_definitions
    @edge_count.times do
      edge = @remainder[0..5]
      source = edge[0..1].unpack('S').first.to_s
      dest   = edge[2..3].unpack('S').first.to_s
      cost   = edge[4..5].unpack('S').first.to_i
      edges << Edge.new(source, dest, cost)
      @remainder = @remainder[6..-1]
    end
  end
end
