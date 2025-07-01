

function result = despachoPerdas()
    clear all;
    clc; 
    format long;
    k = 1;
    epslon = 10^-6;
    a = [0.008, 0.0096]*10^4;
    b = [8.0, 6.4]*100;
    demanda = 5.00;
    min = [1.00, 1.00];
    max = [6.25, 6.25];
    merito = despachoMerito(a,b,demanda,min,max);
   
    variacaoPreco(k) = 0.0;
    preco(k) = (merito.lambda + variacaoPreco(k))/100;
    matB = 10^-3*[8.383183, -0.049488, 0.750164/2; -0.049488, 5.963568, 0.389942/2; 0.750164/2, 0.389942/2, 0.090121];

    sistemalinear{k} = solveSistemaLinear(a, b, preco(k), matB);

    pg{k} =sistemalinear{k}.pg;
    pl(k) = calculoPerdas(sistemalinear{k}.b, matB, pg{k});
    mismatch(k) = abs(soma(pg{k}) - demanda - pl(k));
    while (mismatch(k) > epslon)

       variacaoPreco(k+1) = deltapreco(demanda, preco, pg, k, pl); 
       preco(k+1) = preco(k) + variacaoPreco(k+1); 
       
       sistemalinear{k+1} = solveSistemaLinear(a, b, preco(k+1), matB);
       pg{k+1} = sistemalinear{k+1}.pg;
       pl(k+1) = calculoPerdas(sistemalinear{k+1}.b, matB, pg{k+1});
       mismatch(k+1) = abs(soma(pg{k+1}) - demanda - pl(k+1));
       
       k = k + 1;
    end
    despacho.nome = 'Despacho com Perdas';
    despacho.pg = pg{1}*100;
    despacho.preco = preco(k);
    despacho.iteracoes = k;
    despacho.S = sistemalinear{1}.S;
    result = despacho;
end

function result = deltapreco(demanda, preco, pg, k, perda) % problema ? o pg muito pequenino
    if k == 1 
        deltaP = ((preco(k)-0)/(soma(pg{k})-0))*(demanda+perda(k)-soma(pg{k}));
    else
        deltaP = ((preco(k)-preco(k-1))/(soma(pg{k})-soma(pg{k-1}))) * (demanda+perda(k)-soma(pg{k}));
    end    
    result = abs(deltaP);
end

function result = solveSistemaLinear(a, b, lambda, matB) % O Pg tem que ser um n?mero bem maior
    [linha,coluna] = size(matB);
    for l = 1 : length(a)
        for c = 1 : length(a)
            if l == c
                newB(l,c) = (a(l)/lambda) + 2 * matB(l,c);
            else
                newB(l,c) = 2 * matB(l,c);
            end
            secondB(c) = ((1 - 2*matB(linha,c)) - (b(c)/lambda));       
        end
    end
%     pg1=subs('pg1');
%     pg2=subs('pg2');
%     pg =  solve(newB * [pg1;pg2] == secondB');


   % pg = secondB'\newB;
    pg = newB\secondB';
    resposta.b = newB;
    resposta.S = secondB;
    resposta.pg = abs(pg);
    result = resposta;
end

function result = calculoPerdas(newB, matB, pg)
    [linha,coluna] = size(matB);
    for i = 1 : length(pg)
        for j = 1 : length(pg)
            if i == j
                diagonal(i) = newB(i,j)*pg(i)^2;
            else
                for k = 1 : length(pg)
                    restante(i) = 2 * newB(i,j) * pg(k);
                end
            end
            extra(i) =  2 * matB(linha,i) * pg(i);
        end
    end
    somaDiagonal = soma(diagonal);
    somaRestante = soma(restante);
    somaExtra = soma(extra);
    pl = somaDiagonal + somaRestante + somaExtra + matB(linha,coluna);
   result = pl; 
end

function result = despachoMerito(valorA,valorB,demanda,min,max)
    merito.nome = 'Despacho por Ordem de Merito';
 
    merito.pgDemanda = demanda;%[250, 350, 500, 700, 900, 1100, 1175, 1250];    
    a.valor = valorA;
    b.valor = valorB;
    for w = 1 : length(a.valor)
        a.checa(w) = 0;
        b.checa(w) = 0;
    end
    pgmin = min;
    pgmax = max;
    
    demandaAparente = 0;
    troca = 0;
    aAparente = a;
    bAparente = b;
    at = aTotal(a);
    bt = bTotal(at,a,b);
    k = 1;
  
    while (k<=length(merito.pgDemanda))
        demandaAparente = merito.pgDemanda(k);
        pgt(k) = merito.pgDemanda(k);
        merito.lambda(k) = at*pgt(k)+bt;       
            for j = 1:length(a.valor)           
                         pg(j).valor = calculoPg(merito.lambda(k),a.valor(j) , b.valor(j));
                         pg(j).posicao = j;
                         pg(j).checa = 0;            
            end   
         while (troca == 0)  
                troca = 1;
                atot = aTotal(aAparente);
                btot = bTotal(atot,aAparente,bAparente);        
                lambda = atot*demandaAparente+btot;
                 for j = 1:length(a.valor)
                     if pg(j).checa == 0   
                         pg(j).valor = calculoPg(lambda, a.valor(j), b.valor(j));
                         pg(j).posicao = j;
                         pg(j).checa = 0;
                         merito.lambda(k) = lambda;
                     end
                 end 
                 for i=1 : length(pg)    
                      if (pg(i).valor < pgmin(i))
                          pg(i).valor = pgmin(i);
                          demandaAparente = demandaAparente - pg(i).valor;
                          pg(i).checa = 1;
                          aAparente.checa(i) = 1;
                          bAparente.checa(i) = 1;
                          troca = 0;        
                      end
                      if (pg(i).valor > pgmax(i))
                          pg(i).valor = pgmax(i);
                          demandaAparente = demandaAparente - pg(i).valor;
                          pg(i).checa = 1;
                          aAparente.checa(i) = 1;
                          bAparente.checa(i) = 1;
                          troca = 0;
                      end   
                 end
         end
         for t=1:length(pg)
             objetivo(t) = objective(pg(t).valor, a.valor(t), b.valor(t));
             merito.pgFinal{k}(t) = pg(t).valor;
         end
        merito.preco(k) = soma(objetivo);
       k = k + 1;
    end
    for l=1:length(merito.pgDemanda)
           merito.pg1(l) = merito.pgFinal{l}(1,1);
           merito.pg2(l) = merito.pgFinal{l}(1,2);
          % merito.pg3(l) = merito.pgFinal{l}(1,3);
    end
    result = merito;
end

function result = aTotal(a)
    for i= 1:length(a.valor)
       if a.checa(i) == 0;
            a_inv(i) = 1/a.valor(i);
       else
           a_inv(i) = 1/0;
       end
    end
    result = 1/soma(a_inv);
end

function result = bTotal(at,a,b)
    for i=1:length(a.valor)
        if b.checa(i) == 0
            resultante(i) = (b.valor(i)/a.valor(i));
        else
            resultante(i) = 0;
        end
    end
    result = at*soma(resultante);
end

function result = calculoPg(lambda, a, b)
pg = (lambda - b)/a;
    result = soma(pg);
end

function result = objective(pg, a, b)
    result = (a/2)*pg^2+b*pg;
end

function result=soma(x)
 soma = 0;
 for i=1:length(x)
    soma = soma + x(i);
 end
 result = soma;
end