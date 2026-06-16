library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_controller is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        call : in STD_LOGIC_VECTOR(9 downto 0);
        floor_sensor : in STD_LOGIC_VECTOR(9 downto 0);
        motor_up : out STD_LOGIC;
        motor_down : out STD_LOGIC;
        door_open : out STD_LOGIC;
        door_close : out STD_LOGIC;
        current_floor : out STD_LOGIC_VECTOR(3 downto 0)
    );
end elevator_controller;

architecture Behavioral of elevator_controller is
    type state_type is (IDLE, MOVING, OPENING_DOOR, DOOR_OPEN_WAIT, CLOSING_DOOR, DOOR_CLOSE_WAIT);
    signal state : state_type := IDLE;

    signal cur_floor : INTEGER range 0 to 9 := 0;
    signal next_floor : INTEGER range 0 to 9 := 0;
    signal target_floors : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal move_dir : STD_LOGIC := '0';
    signal door_timer : INTEGER range 0 to 3 := 0;
begin

    process(clk, reset)
        variable min_dist : integer;
        variable chosen : integer;
    begin
        if reset = '1' then
            state <= IDLE;
            cur_floor <= 0;
            target_floors <= (others => '0');
        elsif rising_edge(clk) then
            for i in 0 to 9 loop
                if call(i) = '1' then
                    target_floors(i) <= '1';
                end if;
            end loop;

            case state is
                when IDLE =>
                    min_dist := 999;
                    chosen := -1;
                    for i in 0 to 9 loop
                        if target_floors(i) = '1' then
                            if abs(i - cur_floor) < min_dist then
                                min_dist := abs(i - cur_floor);
                                chosen := i;
                            end if;
                        end if;
                    end loop;

                    if chosen /= -1 then
                        next_floor <= chosen;
                        if chosen > cur_floor then
                            move_dir <= '1';
                            motor_up <= '1';
                            motor_down <= '0';
                        elsif chosen < cur_floor then
                            move_dir <= '0';
                            motor_up <= '0';
                            motor_down <= '1';
                        else
                            motor_up <= '0';
                            motor_down <= '0';
                            state <= OPENING_DOOR;
                        end if;
                        state <= MOVING;
                    end if;

                when MOVING =>
                    if floor_sensor(cur_floor) = '1' then
                        motor_up <= '0';
                        motor_down <= '0';
                        state <= OPENING_DOOR;
                    end if;

                when OPENING_DOOR =>
                    door_open <= '1';
                    door_close <= '0';
                    door_timer <= 0;
                    state <= DOOR_OPEN_WAIT;

                when DOOR_OPEN_WAIT =>
                    if door_timer = 3 then
                        door_open <= '0';
                        state <= CLOSING_DOOR;
                    else
                        door_timer <= door_timer + 1;
                    end if;

                when CLOSING_DOOR =>
                    door_close <= '1';
                    state <= DOOR_CLOSE_WAIT;

                when DOOR_CLOSE_WAIT =>
                    door_close <= '0';
                    target_floors(cur_floor) <= '0';
                    state <= IDLE;

                when others =>
                    null;
            end case;
        end if;
        current_floor <= std_logic_vector(to_unsigned(cur_floor, 4));
    end process;
end Behavioral;

