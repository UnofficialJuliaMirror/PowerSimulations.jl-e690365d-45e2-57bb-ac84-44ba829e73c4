struct Thermal end

function dispatch(m::JuMP.Model, devices_netinjection::T, network:: N, sys::PowerSystems.PowerSystem, constraints::Array{<:Function}) where T <: PowerExpressionArray

    pth, inyection_array = activepowervariables(m, devices_netinjection, sys.generators.thermal, sys.time_periods);

        for c in constraints

            m = c(m, sys.generators.thermal, sys.time_periods)

        end

    return m, devices_netinjection

end

function commitment(m::JuMP.Model, devices_netinjection::T, sys::PowerSystems.PowerSystem, constraints::Array{<:Function}) where T <: PowerExpressionArray

    pth, inyection_array = activepowervariables(m, devices_netinjection, sys.generators.thermal, sys.time_periods);

    on_thermal, start_thermal, stop_thermal = commitmentvariables(m, sys.generators.thermal, sys.time_periods)

    for c in constraints

        # TODO: Find a smarter way to pass on the variables, or rewrite to pass just m and call the variable from inside the function.

        m = c(m, sys.generators.thermal, sys.time_periods, true)

    end

    return m, devices_netinjection

end

function constructdevice(category::Type{Thermal}, transmission::N, m::JuMP.Model, devices_netinjection::T, sys::PowerSystems.PowerSystem, constraints::Array{<:Function}=[powerconstraints]) where {T <: PowerExpressionArray, N <: RealNetwork}

    if commitmentconstraints in constraints

        m, devices_netinjection = commitment(m, devices_netinjection, sys, constraints)

    else

        m, devices_netinjection = dispatch(m, devices_netinjection, sys, constraints)

    end

    return m, devices_netinjection
end