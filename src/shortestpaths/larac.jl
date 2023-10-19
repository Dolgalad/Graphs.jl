"""LARAC algorithm for constrained shortest paths
"""

function shortest_path(g, src, dst, weights)
    ds = dijkstra_shortest_paths(g, src, weights)
    return enumerate_paths(ds, dst)
end

function path_weight(p, weights)
    w = 0.0
    for i in 2:length(p)
        w += weights[p[i-1], p[i]]
    end
    return w
end

function larac_shortest_path(g, src, dst, ub, cost, delay; maxit=100)
    p_c = shortest_path(g, src, dst, cost)
    p_c_delay = path_weight(p_c, delay)
    if p_c_delay <= ub
        return p_c
    end
    p_d = shortest_path(g, src, dst, delay)
    p_d_delay = path_weight(p_d, delay)
    if p_d_delay > ub
        return Int64[]
    end
    for it in 1:maxit
        λ = (path_weight(p_c, cost) - path_weight(p_d, cost)) / (path_weight(p_d, delay) - path_weight(p_c, delay))
        c_l = cost + λ * delay
        r = shortest_path(g, src, dst, c_l)
        if path_weight(r, c_l) == path_weight(p_c, c_l)
            return p_d
        end
        if path_weight(r, delay) <= ub
            p_d = r
        else
            p_c = r
        end
    end
    println("Reached max iter")
    return p_d
end
