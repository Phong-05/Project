library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_controller_tb is
end elevator_controller_tb;

architecture Behavioral of elevator_controller_tb is

    -- Signal declarations
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '1';
    signal call          : std_logic_vector(9 downto 0) := (others => '0');
    signal floor_sensor  : std_logic_vector(9 downto 0) := (others => '0');
    signal motor_up      : std_logic;
    signal motor_down    : std_logic;
    signal door_open     : std_logic;
    signal door_close    : std_logic;
    signal current_floor : std_logic_vector(3 downto 0);

begin

    -- Clock generation (100 MHz -> 10 ns period)
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Instantiate the elevator controller
    uut: entity work.elevator_controller
        port map (
            clk           => clk,
            reset         => reset,
            call          => call,
            floor_sensor  => floor_sensor,
            motor_up      => motor_up,
            motor_down    => motor_down,
            door_open     => door_open,
            door_close    => door_close,
            current_floor => current_floor
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Wait a few cycles
        wait for 50 ns;

        -- Simulate a call from floor 5
        call(5) <= '1';
        wait for 20 ns;
        call(5) <= '0';

        -- Simulate elevator moving to floor 5 step-by-step
        for i in 0 to 5 loop
            floor_sensor <= (others => '0');
            floor_sensor(i) <= '1';
            wait for 50 ns;
        end loop;

        -- Wait at floor 5 (for door open/close)
        wait for 200 ns;

        -- Simulate another call from floor 2
        call(2) <= '1';
        wait for 20 ns;
        call(2) <= '0';

        -- Simulate elevator moving back to floor 2
        for i in 5 downto 2 loop
            floor_sensor <= (others => '0');
            floor_sensor(i) <= '1';
            wait for 50 ns;
        end loop;

        -- Wait at floor 2
        wait for 200 ns;

        -- Finish simulation
        wait for 100 ns;
        assert false report "Simulation finished." severity failure;
    end process;

end Behavioral;
