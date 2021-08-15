def register(params)
    require "redis";
    $rc = Redis.new(:write_timeout => 5, :read_timeout => 5, :reconnect_attempts => 999999, url: "redis://localhost:6379/0")

    @prefix = params["prefix"];
	@fields = params["fields"];
    @ttl = params["ttl"]
end


def filter(event)
    begin
        fields_values = @fields.map { |n| event.get(n).to_s }
        combined = @prefix.to_s + fields_values.join("_")
        if $rc.exists?(combined)
            return []
        end
        $rc.set(combined, nil, ex: @ttl)
        return [event];
    rescue
        return [event];
    end
end