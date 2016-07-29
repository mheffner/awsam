module Awsam
  module Ec2

    LOOKUP_TAGS = ["Name", "aws:autoscaling:groupName", "AlsoKnownAs"].freeze

    def self.instance_hostname(inst)
      # Always use private IP address
      inst.private_ip_address
    end

    def self.find_instance(acct, instance_id)
      ec2 = Aws::EC2::Client.new(:access_key_id => acct.access_key,
                                 :secret_access_key => acct.secret_key,
                                 :region => acct.aws_region)

      unless ec2
        puts "Unable to connect to EC2"
        return nil
      end

      find(ec2, instance_id)
    end

    def self.find(ec2, instance_id)
      if instance_id =~ /^i-[0-9a-f]{8,17}$/
        find_by_instance_id(ec2, instance_id)
      else
        find_by_tag(ec2, instance_id)
      end
    end

    def self.find_by_instance_id(ec2, instance_id)
      begin
        resp = ec2.describe_instances(:instance_ids => [instance_id])
        resp.reservations.length > 0 ? resp.reservations[0].instances.first : nil
      rescue => e
        puts "error describing instance: #{instance_id}: #{e}"
        exit 1
      end
    end

    def self.find_by_tag(ec2, instance_id)
      results = []

      params = {
        :filters => [{
                       :name => "resource-type",
                       :values => ["instance"]
                     }]
      }
      resp = ec2.describe_tags(params)
      resp.tags.each do |tag|
        if LOOKUP_TAGS.include?(tag.key) &&
            tag.value.downcase.include?(instance_id.downcase)
          results << tag
        end
      end

      if !results || results.length == 0
        puts "No tags by this name are available in your account"
        exit 1
      end

      results.uniq! { |a| a.resource_id }
      results.sort! { |a,b| a.value <=> b.value }

      rmap = {}
      params = {
        :instance_ids => results.map{|a| a.resource_id},
        :filters => [{
                       :name => "instance-state-name",
                       :values => ["running"]
                     }]
      }
      resp = ec2.describe_instances(params)
      resp.reservations.each do |resv|
        resv.instances.each do |inst|
          rmap[inst.instance_id] = inst
        end
      end

      results.reject! { |a| rmap[a.resource_id].nil? }

      if results.length == 0
        puts "No running instances by that tag name are available"
        exit 1
      end

      if $opts[:first_node] || results.length == 1
        node = results.first
      else
        puts "Please select which node you wish to use:"
        puts

        namemax = 0
        instmax = 0
        ipmax = 0
        results.each_with_index do |elem, i|
          inst = rmap[elem.resource_id]
          if elem.value.length > namemax
            namemax = elem.value.length
          end
          if inst.instance_id.length > instmax
            instmax = inst.instance_id.length
          end
          if inst.private_ip_address.length > ipmax
            ipmax = inst.private_ip_address.length
          end
        end

        countmax = results.size.to_s.length
        results.each_with_index do |elem, i|
          inst = rmap[elem.resource_id]

          launchtime = inst.launch_time
          puts "%*d) %-*s (%*s %-*s %-11s %s %s)" %
            [countmax, i + 1,
             namemax, elem.value,
             instmax, inst.instance_id,
             ipmax, inst.private_ip_address,
             inst.instance_type,
             inst.placement.availability_zone,
             launchtime.strftime("%Y-%m-%d")]
        end
        puts "%*s) Quit" % [countmax, "q"]
        puts

        print "> "
        input = $stdin.gets
        puts
        exit unless input =~ /^\d+$/
        sel = input.to_i
        exit unless sel > 0 && sel <= results.size

        node = results[sel - 1]
      end

      return rmap[node.resource_id]
    end
  end
end
