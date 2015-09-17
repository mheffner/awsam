module Awsam
  module Ec2

    LOOKUP_TAGS = ["Name", "aws:autoscaling:groupName"].freeze

    def self.instance_hostname(inst)
      hostname = inst[:dns_name]
      if hostname.to_s.length == 0
        # Are we in a VPC?
        hostname = inst[:private_dns_name]
      end
      hostname
    end

    def self.find_instance(acct, instance_id)
      logger = Logger.new(File.open("/dev/null", "w"))
      ec2 = RightAws::Ec2.new(acct.access_key, acct.secret_key, :logger => logger)
      
      unless ec2
        puts "Unable to connect to EC2"
        return nil
      end

      find(ec2, instance_id)
    end
    
    def self.find(ec2, instance_id)
      if instance_id =~ /^i-[0-9a-f]{7,9}$/
        find_by_instance_id(ec2, instance_id)
      else
        find_by_tag(ec2, instance_id)
      end
    end
    
    def self.find_by_instance_id(ec2, instance_id)
      begin
        ec2.describe_instances(instance_id).first
      rescue RightAws::AwsError
        puts "instance_id does not exist"
        exit 1
      end
    end
    
    def self.find_by_tag(ec2, instance_id)
      results = []

      ec2.describe_tags(:filters => {
                          "resource-type" => "instance"
                        }).each do |tag|
        if LOOKUP_TAGS.include?(tag[:key]) &&
            tag[:value].downcase.include?(instance_id.downcase)
          results << tag
        end
      end

      if !results || results.length == 0
        puts "No tags by this name are available in your account"
        exit 1
      end
      
      results.uniq! { |a| a[:resource_id] }
      results.sort! { |a,b| a[:value] <=> b[:value] }

      rmap = {}
      ec2.describe_instances(results.map{|a| a[:resource_id]},
                             :filters => {
                               "instance-state-name" => "running"
                             }).each do |inst|
        rmap[inst[:aws_instance_id]] = inst
      end

      results.reject! { |a| rmap[a[:resource_id]].nil? }

      if results.length == 0
        puts "No running instances by that tag name are available"
        exit 1
      end

      if $opts[:first_node] || results.length == 1
        node = results.first
      else
        puts "Please select which node you wish to use:"
        puts

        results.each_with_index do |elem, i|
          inst = rmap[elem[:resource_id]]
          puts "%d) %s (%s, %s, %s)" %
            [i, elem[:value], inst[:aws_instance_id],
             inst[:aws_instance_type], inst[:aws_launch_time]]
        end
        puts "q) Quit"
        puts

        print "> "
        input = $stdin.gets
        puts
        exit unless input =~ /^\d+$/
        node = results[input.to_i]
      end

      return rmap[node[:resource_id]]
    end
  end
end
