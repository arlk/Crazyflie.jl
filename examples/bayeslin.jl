using DelimitedFiles

using LinearAlgebra
using DSP: conv

function derivative(signal, order, halflen, dt)
    @assert 2*halflen ≥ order ≥ 0
    @assert iseven(halflen)
    S = (-halflen:halflen)' .^ (0:order);
    F = qr(S')
    filter = Matrix(F.Q)/Matrix(F.R')
    der = conv(signal, 1/-dt*filter[:, 2])
    return der[halflen+1:end-halflen]
end

function bayeslinreg(dΩ, Ω, U, σ, μβ, invΣβ)
    p = Ω[:,1]; q = Ω[:,2]; r = Ω[:,3]
    ψ = hcat(p.^2, q.^2, r.^2, p.*q, p.*r, q.*r, U)'
    invA = inv(1/σ^2*ψ*ψ' + invΣβ)
    μ(y) = 1/σ^2*invA*(ψ*y + invΣβ*μβ)
    μ.(eachcol(dΩ)), invA
end

σ = 1.0
μβ = zeros(9)
invΣβ = inv(diagm(0=>ones(9)))
Ω = readdlm("/tmp/omega.txt")
U = readdlm("/tmp/controls.txt")
dΩ = hcat(derivative.(eachcol(Ω), 4, 30, 0.01)...)

using MAT
file = matopen("/home/arun/Documents/shared-scripts/learning.mat", "w")
write(file, "cflie", hcat(dΩ, Ω, U))
close(file)

# slice some inbetween data to train
#  Ω = Ω[251:500,:]
#  U = U[251:500,:]
#  dΩ = dΩ[251:500,:]

postμ, postσ = bayeslinreg(dΩ, Ω, U, σ, μβ, invΣβ)

## for testing only
function predictivedist(Ωx, Ux, postμ, postσ, σ)
    p, q, r = Ωx
    ψx = [p^2, q^2, r^2, p*q, p*r, q*r, Ux...]
    μ = Ref(ψx').*postμ
    σ = ψx'*postσ*ψx .+ σ^2
    μ, σ
end
pred = predictivedist.(eachrow(Ω), eachrow(U), Ref(postμ), Ref(postσ), Ref(σ))
predx = [p[2][2] for p in pred]
plot(dΩ[:,2]); plot!(predx)
