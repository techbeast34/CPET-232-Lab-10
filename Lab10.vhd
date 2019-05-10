--Satyendra Emani--
--Lab 10: Vending Machine State Machine
--CPET-232-01

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY Lab10 IS
	PORT(
	Nickel_In	:IN STD_LOGIC;
	Dime_In		:IN STD_LOGIC;
	Quarter_In	:IN STD_LOGIC;
	Dispense	:IN STD_LOGIC;
	Coin_Return	:IN STD_LOGIC;
	clk, reset_n:IN STD_LOGIC;
	Red_Bull	:OUT STD_LOGIC;
	Change_back	:OUT STD_LOGIC;
	HEX1, HEX0	:OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END Lab10;

ARCHITECTURE model OF Lab10 IS
	TYPE state_type IS (wait1, dime, nickel, quarter, enough, excess, vend, change);
	SIGNAL current_state, next_state : state_type;
	SIGNAL money :UNSIGNED(6 DOWNTO 0) := "0000000";
	
	COMPONENT ssd_driver
		PORT(In_num			:IN STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX1, HEX0	    :OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;
	
BEGIN
	sync : PROCESS(reset_n, clk) --Sync process
	BEGIN
		IF(reset_n = '0') THEN
			current_state <= wait1;
		ELSIF(rising_edge(clk)) THEN
			current_state <= next_state;
		END IF;
	END PROCESS;
	
	--State Machine Transitioner
	PROCESS(current_state, Nickel_In, Dime_In, Quarter_In, Dispense, Coin_Return, money)
	BEGIN
		CASE(current_state) IS
			WHEN wait1 =>
				IF(Dime_In = '1') THEN
					next_state <= dime;
				ELSIF(Nickel_In = '1') THEN
					next_state <= nickel;
				ELSIF(Quarter_In = '1') THEN
					next_state <= quarter;
				ELSIF(Coin_Return = '1') THEN
					next_state <= change;
				ELSIF(money >= 75) THEN
					next_state <= enough;
				ELSE
					next_state <= wait1;
				END IF;
			WHEN dime =>
				IF(money >= 75) THEN
					next_state <= enough;
				ELSE
					next_state <= wait1;
				END IF;
			WHEN nickel => 
				IF(money >= 75) THEN
					next_state <= enough;
				ELSE
					next_state <= wait1;
				END IF;
			WHEN quarter =>
				IF(money >= 75) THEN
					next_state <= enough;
				ELSE
					next_state <= wait1;
				END IF;
			WHEN enough =>
				IF(Dispense = '1') THEN
					next_state <= vend;
				ELSIF((Nickel_In = '1') OR (Dime_In = '1') OR (Quarter_In = '1')) THEN
					next_state <= excess;
				ELSIF(Coin_Return = '1') THEN
					next_state <= change;
				ELSE
					next_state <= enough;
				END IF;
			WHEN excess =>
				IF(Dispense = '1') THEN
					next_state <= vend;
				ELSIF((Nickel_In = '1') OR (Dime_In = '1') OR (Quarter_In = '1')) THEN
					next_state <= excess;
				ELSIF(Coin_Return = '1') THEN
					next_state <= change;
				ELSE
					next_state <= enough;
				END IF;
			WHEN vend =>
				IF(money > 0) THEN
					next_state <= change;
				ELSE
					next_state <= wait1;
				END IF;
			WHEN change =>
				next_state <= wait1;
			WHEN OTHERS =>
				next_state <= wait1;
			END CASE;
	END PROCESS;
	
	PROCESS(next_state, money, clk) --Keeps track of money
	BEGIN
		IF(reset_n = '0') THEN
			money <= "0000000";
		ELSIF(rising_edge(clk)) THEN
			CASE(next_state) IS
				WHEN wait1 =>
					money <= money;
				WHEN dime =>
					money <= money + 10;
				WHEN nickel => 
					money <= money + 5;
				WHEN quarter =>
					money <= money + 25;
				WHEN enough =>
					money <= money;
				WHEN excess =>
					money <= money;
				WHEN vend =>
					money <= money - 75;
				WHEN change =>
					money <= "0000000";
				WHEN OTHERS =>
					money <= money;
			END CASE;
		END IF;
	END PROCESS;

	change_proc: PROCESS(current_state) --Keeps track of change
	BEGIN
		CASE(current_state) IS
			WHEN change =>
				Change_back <= '1';
			WHEN OTHERS =>
				Change_back <= '0';
		END CASE;
	END PROCESS;
	
	dispense_proc: 	PROCESS(current_state) --Keeps track of change
	BEGIN
		CASE(current_state) IS
			WHEN vend =>
				Red_Bull <= '1';
			WHEN OTHERS =>
				Red_Bull <= '0';
		END CASE;
	END PROCESS;
	
	U1: ssd_driver PORT MAP(STD_LOGIC_VECTOR(money), HEX1, HEX0);
	
END model;