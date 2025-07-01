function result = despachoMerito()
    clear all;
    clc; 
    merito.nome = 'Despacho por Ordem de Merito';
 
    merito.pgDemanda = 500;%[250, 350, 500, 700, 900, 1100, 1175, 1250];    
    a.valor = [0.008, 0.0096];
    b.valor = [8.0, 6.4];
    for w = 1 : length(a.valor)
        a.checa(w) = 0;
        b.checa(w) = 0;
    end
    pgmin = [100, 100];
    pgmax = [625, 625];

%    merito.pgDemanda = [650];
%    a.valor = [0.00043, 0.00063, 0.00039];
%    a.checa = [0,0,0];
%    b.valor = [21.60, 21.05,   20.81];
%    b.checa = [0,0,0];
%    pgmin=[150.0, 135.0, 73.0] ;
%    pgmax=[470.0, 460.0, 340.0];
      
%    merito.pgDemanda = [850];   
%    a.valor = [0.001562, 0.00482, 0.00194];
%    a.checa = [0,0,0];
%    b.valor = [7.92, 7.97, 7.85];
%    b.checa = [0,0,0];
%    pgmin = [100, 50, 100];
%    pgmax = [600, 200, 400];

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
       end
    end
    result = 1/soma(a_inv);
end

function result = bTotal(at,a,b)
    for i=1:length(a.valor)
        if b.checa(i) == 0
            resultante(i) = (b.valor(i)/a.valor(i));
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