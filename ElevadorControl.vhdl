library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Declaração da entidade do controle do elevador
entity ElevatorControl is
    Port (
        clock : in STD_LOGIC;  -- Sinal de clock
        reset : in STD_LOGIC;  -- Reset do sistema
        call_floor : in STD_LOGIC_VECTOR(3 downto 0); -- Chamadas dos andares (4 bits para 4 andares)
        sensor_floor : in STD_LOGIC_VECTOR(3 downto 0); -- Sensores dos andares (4 bits para 4 andares)
        motor_up : out STD_LOGIC; -- Motor para subir
        motor_down : out STD_LOGIC; -- Motor para descer
        motor_stop : out STD_LOGIC -- Motor para parar
    );
end ElevatorControl;

-- Arquitetura do controle
architecture Behavioral of ElevatorControl is
    -- Definição dos estados
    type State_Type is (IDLE, MOVING_UP, MOVING_DOWN, STOPPED);
    signal state : State_Type := IDLE;
    signal next_state : State_Type := IDLE;
    signal current_floor : INTEGER range 0 to 3 := 0; -- Andar atual do elevador

begin

    -- Lógica de transição de estado
    process(clock, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            current_floor <= 0; -- Reset para o andar térreo
        elsif rising_edge(clock) then
            state <= next_state;
        end if;
    end process;

    -- Lógica de saída com base no estado
    process(state, call_floor, sensor_floor)
    begin
        motor_up <= '0';
        motor_down <= '0';
        motor_stop <= '1';

        case state is
            when IDLE =>
                -- Verifique se há alguma chamada e mova o elevador
                if call_floor /= "0000" then
                    for i in 0 to 3 loop
                        if call_floor(i) = '1' and i > current_floor then
                            next_state <= MOVING_UP;
                            exit;
                        elsif call_floor(i) = '1' and i < current_floor then
                            next_state <= MOVING_DOWN;
                            exit;
                        end if;
                    end loop;
                end if;

            when MOVING_UP =>
                motor_stop <= '0';
                motor_up <= '1';
                -- Verifique se o elevador alcançou o andar chamado
                if sensor_floor(current_floor) = '1' then
                    next_state <= STOPPED;
                else
                    current_floor <= current_floor + 1;
                end if;

            when MOVING_DOWN =>
                motor_stop <= '0';
                motor_down <= '1';
                -- Verifique se o elevador alcançou o andar chamado
                if sensor_floor(current_floor) = '1' then
                    next_state <= STOPPED;
                else
                    current_floor <= current_floor - 1;
                end if;

            when STOPPED =>
                motor_stop <= '1';
                -- Desligue o motor e aguarde a próxima chamada
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;
