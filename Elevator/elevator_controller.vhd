-- Improved Elevator Controller in VHDL
-- Modular: Scheduler, Motion, Door Controller

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_controller is
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        call            : in  STD_LOGIC_VECTOR(9 downto 0); 
        floor_sensor    : in  STD_LOGIC_VECTOR(9 downto 0); 
        motor_up        : out STD_LOGIC;
        motor_down      : out STD_LOGIC;
        door_open       : out STD_LOGIC; 
        door_close      : out STD_LOGIC;  
        current_floor   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end elevator_controller;

architecture Behavioral of elevator_controller is

    -- Scheduler internal queues
    signal up_requests   : STD_LOGIC_VECTOR(9 downto 0) := (others=>'0');
    signal down_requests : STD_LOGIC_VECTOR(9 downto 0) := (others=>'0');
    signal next_floor    : integer range 0 to 9 := 0;
    signal has_request   : STD_LOGIC := '0';

    -- Motion controller
    signal cur_floor_i   : integer range 0 to 9 := 0;
    signal move_dir      : STD_LOGIC := '0';  -- '1'=up, '0'=down
    signal moving        : STD_LOGIC := '0';

    -- Door controller
    type door_state_t is (D_IDLE, D_OPEN, D_WAIT, D_CLOSE);
    signal door_state    : door_state_t := D_IDLE;
    signal door_timer    : integer range 0 to 3 := 0;

begin

    -- Update current floor from floor_sensor
    process(clk, reset)
    begin
        if reset='1' then
            cur_floor_i <= 0;
        elsif rising_edge(clk) then
            for i in 0 to 9 loop
                if floor_sensor(i)='1' then
                    cur_floor_i <= i;
                end if;
            end loop;
        end if;
    end process;
    current_floor <= std_logic_vector(to_unsigned(cur_floor_i, 4));

    -- Scheduler: capture calls and select next
    process(clk, reset)
        variable up_min_dist   : integer;
        variable down_min_dist : integer;
        variable sel           : integer;
    begin
        if reset='1' then
            up_requests   <= (others=>'0');
            down_requests <= (others=>'0');
            next_floor    <= 0;
            has_request   <= '0';
        elsif rising_edge(clk) then
            -- Latch new calls
            for i in 0 to 9 loop
                if call(i)='1' then
                    if i > cur_floor_i then
                        up_requests(i) <= '1';
                    elsif i < cur_floor_i then
                        down_requests(i) <= '1';
                    else
                        -- same floor: service immediately
                        has_request <= '1';
                        next_floor <= i;
                    end if;
                end if;
            end loop;

            -- Determine next destination if idle
            if moving='0' and door_state=D_IDLE then
                -- Prioritize same-floor immediate
                if has_request='1' then
                    null;
                else
                    -- If moving was up or no requests above
                    up_min_dist := 999;
                    down_min_dist := 999;
                    sel := -1;
                    -- find nearest up request
                    for i in cur_floor_i+1 to 9 loop
                        if up_requests(i)='1' then
                            if (i-cur_floor_i)<up_min_dist then
                                up_min_dist := i-cur_floor_i;
                                sel := i;
                                move_dir <= '1';
                            end if;
                        end if;
                    end loop;
                    -- find nearest down request
                    for i in 0 to cur_floor_i-1 loop
                        if down_requests(i)='1' then
                            if (cur_floor_i-i)<down_min_dist then
                                down_min_dist := cur_floor_i-i;
                                sel := i;
                                move_dir <= '0';
                            end if;
                        end if;
                    end loop;
                    if sel /= -1 then
                        next_floor <= sel;
                        has_request <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Motion Controller: drive motors
    process(clk, reset)
    begin
        if reset='1' then
            motor_up   <= '0';
            motor_down <= '0';
            moving     <= '0';
        elsif rising_edge(clk) then
            if has_request='1' then
                if cur_floor_i < next_floor then
                    moving <= '1'; motor_up <= '1'; motor_down <= '0';
                elsif cur_floor_i > next_floor then
                    moving <= '1'; motor_up <= '0'; motor_down <= '1';
                else
                    moving <= '0'; motor_up <= '0'; motor_down <= '0';
                end if;
            else
                moving <= '0'; motor_up <= '0'; motor_down <= '0';
            end if;
        end if;
    end process;

    -- Door Controller
    process(clk, reset)
    begin
        if reset='1' then
            door_state <= D_IDLE;
            door_open  <= '0';
            door_close <= '0';
            door_timer <= 0;
        elsif rising_edge(clk) then
            case door_state is
                when D_IDLE =>
                    if moving='0' and has_request='1' and cur_floor_i=next_floor then
                        door_state <= D_OPEN;
                    end if;

                when D_OPEN =>
                    door_open  <= '1';
                    door_close <= '0';
                    door_timer <= 0;
                    door_state <= D_WAIT;

                when D_WAIT =>
                    if door_timer=3 then
                        door_open <= '0';
                        door_state <= D_CLOSE;
                    else
                        door_timer <= door_timer+1;
                    end if;

                when D_CLOSE =>
                    door_close <= '1';
                    door_state <= D_IDLE;
                    -- clear request
                    if next_floor>cur_floor_i then
                        up_requests(next_floor) <= '0';
                    elsif next_floor<cur_floor_i then
                        down_requests(next_floor) <= '0';
                    else
                        -- same floor, clear both
                        up_requests(next_floor)   <= '0';
                        down_requests(next_floor) <= '0';
                    end if;
                    has_request <= '0';
                    door_close <= '0';
            end case;
        end if;
    end process;

end Behavioral;
