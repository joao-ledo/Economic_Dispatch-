% ======================================================================= %
%                                                                         %
%                          UNIT COMMITMENT ALGORITHM                      %
%               (USING THE MERIT ORDER ECONOMIC DISPATCH METHOD)          %
%                                                                         %
%                                    Developed by Joao Augusto Silva Ledo %
% ======================================================================= %

function result = UnitCommitment()

    clear all;
    clc;
    
    demanda = [1100, 1400, 1600, 1800, 1400, 1100];
    a = [0.008, 0.0096, 0.01, 0.011];
    b = [8.0, 6.4, 7.9, 7.5];
    c = [500, 400, 600, 400];
    menor =[100, 100, 75, 75];
    max = [625, 625, 600, 500];  
    combinacoes = {[1,1,1,1],[1,1,1,0],[1,1,0,1],[1,1,0,0]};

    mat_periodos = configuracaoDoDia(a,b,c,demanda,menor,max,combinacoes); % Loads the daily settings in periods without the dispatched power

    mat_periodos = Backward(mat_periodos); % Unit Commitment Backward movement ON and OFF inputting values to the generating units

    Final_Array = Forward(mat_periodos); % Unit Commitment Forward movement creating the final output array with Dispatched Power Values
    
    result = Final_Array;
end

%_________________________________________________________________________%
%                                                                         %
%                                FORWARD                                  %
%_________________________________________________________________________%
function result = Forward(dia)
    for p = 1 : length(dia)
        for q = 1 : length(dia{p})
            melhoravaliacao{p}(q) = dia{p}(q).melhoravaliacao; % Createsa a cell array holding in each of its position the best generating units based on the Merit Order Dispatch Method for each period of the day
        end
        best(p) = min(melhoravaliacao{p}); % Finds the best velues among the best for each period
    end   
    for i =1:length(dia)
        for j = 1:length(dia{i})
            if dia{i}(j).melhoravaliacao == best(i)
                resultado{i} = dia{i}(j); % Finds in the cell array matrix day (dia) the unit that holds the best cost value among the units found in the array "best"
            end
        end
    end
    result = resultado;
end

%_________________________________________________________________________%
%                                                                         %
%                               BACKWARD                                  %
%_________________________________________________________________________%
function result = Backward(dia)
    dia = despacho(dia); % Dispatches each geneting units for the day according to its pre-setting
    dia{6}(1).avaliacao = dia{6}(1).precos{1}; % The first period holds its evaluated value based on its cost
    for i = length(dia) : -1:1
             if i == 1
                break; 
             end
        for k=1:length(dia{i-1})
            for j = 1 : length(dia{i})
                dia{i-1}(k).avaliacao(j) = [Avaliacao(dia{i-1}(k),dia{i}(j))]; % Calculates all possiable evaluated values of each generating unit for each period
            end
        end
    end
    for p = 1 : length(dia)
        for q = 1: length(dia{p}) 
           dia{p}(q).melhoravaliacao = min(dia{p}(q).avaliacao); % Finds the best evaluated value of ech generating unit for each period
           
        end
    end
    result = dia;
end
    
%_________________________________________________________________________%
%                                                                         %
%                 TURNING ON AND OFF FUNCTION BACKWARD MOVEMENT           %
%_________________________________________________________________________%
function result = Avaliacao(anterior,atual)
    T = 0;
    for i = 1:length(atual.configuracao)
        if(atual.configuracao(i) == anterior.configuracao(i))
            T = T + 0;
        else if (anterior.configuracao(i) == 1)
                T = T + 1500;
            else
                T = T + 3000;
            end
        end
    end
    F = anterior.precos{1}+T+min(atual.avaliacao);
    result = F;
end

%_________________________________________________________________________%
%                                                                         %
%       CALLS THE MERIT ORDER ECONOMIC DISPATCH FUNCTION FOR THE DAY      %
%_________________________________________________________________________%
function result = despacho(dia)
    for i = 1 : length(dia)
       for j = 1 : length(dia{i}) 
            aux = despachoMerito(dia{i}(j).a,dia{i}(j).b,dia{i}(j).c,dia{i}(j).d,dia{i}(j).min,dia{i}(j).max);
            dia{i}(j).Pg = aux(1);
            dia{i}(j).precos = aux(2);
       end
    end
    result = dia;
end

%_________________________________________________________________________%
%                                                                         %
%                CREATES THE SETTINGS MATRIX FOR THE DAY                  %
%_________________________________________________________________________%
function result = configuracaoDoDia(a,b,c,demanda,min,max,combinacoes)  

%    periodo 1-------------------------------------------------------------
     periodo1(1).a = multiplicadorBinario(a,combinacoes{4});
     periodo1(1).b = multiplicadorBinario(b,combinacoes{4});
     periodo1(1).c = multiplicadorBinario(c,combinacoes{4});
     periodo1(1).d = multiplicadorBinario(demanda(1),combinacoes{4});
     periodo1(1).min = multiplicadorBinario(min,combinacoes{4});
     periodo1(1).max = multiplicadorBinario(max,combinacoes{4});
     periodo1(1).configuracao = combinacoes{4};
     
%    periodo 2-------------------------------------------------------------
     periodo2(1).a = multiplicadorBinario(a,combinacoes{1});
     periodo2(1).b = multiplicadorBinario(b,combinacoes{1});
     periodo2(1).c = multiplicadorBinario(c,combinacoes{1});
     periodo2(1).d = multiplicadorBinario(demanda(2),combinacoes{1});
     periodo2(1).min = multiplicadorBinario(min,combinacoes{1});
     periodo2(1).max = multiplicadorBinario(max,combinacoes{1});
     periodo2(1).configuracao = combinacoes{1};
     
     periodo2(2).a = multiplicadorBinario(a,combinacoes{2});
     periodo2(2).b = multiplicadorBinario(b,combinacoes{2});
     periodo2(2).c = multiplicadorBinario(c,combinacoes{2});
     periodo2(2).d = multiplicadorBinario(demanda(2),combinacoes{2});
     periodo2(2).min = multiplicadorBinario(min,combinacoes{2});
     periodo2(2).max = multiplicadorBinario(max,combinacoes{2});
     periodo2(2).configuracao = combinacoes{2};
     
     periodo2(3).a = multiplicadorBinario(a,combinacoes{3});
     periodo2(3).b = multiplicadorBinario(b,combinacoes{3});
     periodo2(3).c = multiplicadorBinario(c,combinacoes{3});
     periodo2(3).d = multiplicadorBinario(demanda(2),combinacoes{3});
     periodo2(3).min = multiplicadorBinario(min,combinacoes{3});
     periodo2(3).max = multiplicadorBinario(max,combinacoes{3});
     periodo2(3).configuracao = combinacoes{3};
     
%    periodo 3-------------------------------------------------------------
     periodo3(1).a = multiplicadorBinario(a,combinacoes{1});
     periodo3(1).b = multiplicadorBinario(b,combinacoes{1});
     periodo3(1).c = multiplicadorBinario(c,combinacoes{1});
     periodo3(1).d = multiplicadorBinario(demanda(3),combinacoes{1});
     periodo3(1).min = multiplicadorBinario(min,combinacoes{1});
     periodo3(1).max = multiplicadorBinario(max,combinacoes{1});
     periodo3(1).configuracao = combinacoes{1};
     
     periodo3(2).a = multiplicadorBinario(a,combinacoes{2});
     periodo3(2).b = multiplicadorBinario(b,combinacoes{2});
     periodo3(2).c = multiplicadorBinario(c,combinacoes{2});
     periodo3(2).d = multiplicadorBinario(demanda(3),combinacoes{2});
     periodo3(2).min = multiplicadorBinario(min,combinacoes{2});
     periodo3(2).max = multiplicadorBinario(max,combinacoes{2});
     periodo3(2).configuracao = combinacoes{2};
     
     periodo3(3).a = multiplicadorBinario(a,combinacoes{3});
     periodo3(3).b = multiplicadorBinario(b,combinacoes{3});
     periodo3(3).c = multiplicadorBinario(c,combinacoes{3});
     periodo3(3).d = multiplicadorBinario(demanda(3),combinacoes{3});
     periodo3(3).min = multiplicadorBinario(min,combinacoes{3});
     periodo3(3).max = multiplicadorBinario(max,combinacoes{3});
     periodo3(3).configuracao = combinacoes{3};
     
%    periodo 4-------------------------------------------------------------
     periodo4(1).a = multiplicadorBinario(a,combinacoes{1});
     periodo4(1).b = multiplicadorBinario(b,combinacoes{1});
     periodo4(1).c = multiplicadorBinario(c,combinacoes{1});
     periodo4(1).d = multiplicadorBinario(demanda(4),combinacoes{1});
     periodo4(1).min = multiplicadorBinario(min,combinacoes{1});
     periodo4(1).max = multiplicadorBinario(max,combinacoes{1});
     periodo4(1).configuracao = combinacoes{1};
     
     periodo4(2).a = multiplicadorBinario(a,combinacoes{2});
     periodo4(2).b = multiplicadorBinario(b,combinacoes{2});
     periodo4(2).c = multiplicadorBinario(c,combinacoes{2});
     periodo4(2).d = multiplicadorBinario(demanda(4),combinacoes{2});
     periodo4(2).min = multiplicadorBinario(min,combinacoes{2});
     periodo4(2).max = multiplicadorBinario(max,combinacoes{2});
     periodo4(2).configuracao = combinacoes{2};
     
%    periodo 5-------------------------------------------------------------
     periodo5(1).a = multiplicadorBinario(a,combinacoes{1});
     periodo5(1).b = multiplicadorBinario(b,combinacoes{1});
     periodo5(1).c = multiplicadorBinario(c,combinacoes{1});
     periodo5(1).d = multiplicadorBinario(demanda(5),combinacoes{1});
     periodo5(1).min = multiplicadorBinario(min,combinacoes{1});
     periodo5(1).max = multiplicadorBinario(max,combinacoes{1});
     periodo5(1).configuracao = combinacoes{1};
     
     periodo5(2).a = multiplicadorBinario(a,combinacoes{2});
     periodo5(2).b = multiplicadorBinario(b,combinacoes{2});
     periodo5(2).c = multiplicadorBinario(c,combinacoes{2});
     periodo5(2).d = multiplicadorBinario(demanda(5),combinacoes{2});
     periodo5(2).min = multiplicadorBinario(min,combinacoes{2});
     periodo5(2).max = multiplicadorBinario(max,combinacoes{2});
     periodo5(2).configuracao = combinacoes{2};
     
     periodo5(3).a = multiplicadorBinario(a,combinacoes{3});
     periodo5(3).b = multiplicadorBinario(b,combinacoes{3});
     periodo5(3).c = multiplicadorBinario(c,combinacoes{3});
     periodo5(3).d = multiplicadorBinario(demanda(5),combinacoes{3});
     periodo5(3).min = multiplicadorBinario(min,combinacoes{3});
     periodo5(3).max = multiplicadorBinario(max,combinacoes{3});
     periodo5(3).configuracao = combinacoes{3};
    
%    periodo 6-------------------------------------------------------------
     periodo6(1).a = multiplicadorBinario(a,combinacoes{4});
     periodo6(1).b = multiplicadorBinario(b,combinacoes{4});
     periodo6(1).c = multiplicadorBinario(c,combinacoes{4});
     periodo6(1).d = multiplicadorBinario(demanda(6),combinacoes{4});
     periodo6(1).min = multiplicadorBinario(min,combinacoes{4});
     periodo6(1).max = multiplicadorBinario(max,combinacoes{4});
     periodo6(1).configuracao = combinacoes{4};
     periodo6(1).avaliacao = [0];
     
    result = {periodo1,periodo2,periodo3,periodo4,periodo5,periodo6};
end

%_________________________________________________________________________%
%                                                                         %
%        MULTIPLAY THE BINARY ON AND OFF ARRAY TO THE ACTUAL UNITS        %
%                         TO BE TURNED ON AND OFF                         %
%_________________________________________________________________________%
function result = multiplicadorBinario(valor, binario)
    for i = 1 : length(valor)
            if binario(i) ~= 0
                resultado(i) = valor(i);    
            end
    end       
    aux = nonzeros(resultado);
    for j = 1 : length(aux)
        resposta(j) = aux(j);    
    end
    result = resposta;
end

%_________________________________________________________________________%
%                                                                         %
%               MERIT ORDER ECONOMIC DISPATCH METHOD FUNCTION             %
%_________________________________________________________________________%
function result = despachoMerito(valorA,valorB,valorC,demanda,min,max)
    merito.nome = 'Merit Order Economic Dispatch Method';
    merito.pgDemanda = demanda;
    a.valor = valorA;
    b.valor = valorB;
    c = valorC;
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
             objetivo(t) = (objective(pg(t).valor, a.valor(t), b.valor(t), c(t)));
             merito.pgFinal{k}(t) = pg(t).valor;
         end
        merito.preco(k) = 4 * (soma(objetivo));
       k = k + 1;
    end
    
    result = {merito.pgFinal{1},merito.preco};
end

%_________________________________________________________________________%
%                                                                         %
% CALCULATES THE aTotal VALUE TO THE MERIT ORDER ECONOMIC DISPATCH METHOD %
%_________________________________________________________________________%
function result = aTotal(a)
    for i= 1:length(a.valor)
       if a.checa(i) == 0
            a_inv(i) = 1/a.valor(i);
       end
    end
    result = 1/soma(a_inv);
end

%_________________________________________________________________________%
%                                                                         %
% CALCULATES THE bTotal VALUE TO THE MERIT ORDER ECONOMIC DISPATCH METHOD %
%_________________________________________________________________________%
function result = bTotal(at,a,b)
    for i=1:length(a.valor)
        if b.checa(i) == 0
            resultante(i) = (b.valor(i)/a.valor(i));
        end
    end
    result = at*soma(resultante);
end

%_________________________________________________________________________%
%                                                                         %
%  FINDS THE GENERATED POWER BY THE MERIT ORDER ECONOMIC DISPATCH METHOD  %
%_________________________________________________________________________%
function result = calculoPg(lambda, a, b)
pg = (lambda - b)/a;
    result = soma(pg);
end

%_________________________________________________________________________%
%                                                                         %
%      OBJECTIVE FUNCTION OF THE MERIT ORDER ECONOMIC DISPATCH METHOD     %
%_________________________________________________________________________%
function result = objective(pg, a, b, c)
    result = (a/2)*pg^2+b*pg+c;
end

%_________________________________________________________________________%
%                                                                         %
%                       SUMMING ARRAY VALUES FUNCTION                     %
%_________________________________________________________________________%
function result=soma(x)
 soma = 0;
 for i=1:length(x)
    soma = soma + x(i);
 end
 result = soma;
end
%________________________________END______________________________________%
