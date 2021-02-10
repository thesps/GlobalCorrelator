library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Int;
use Int.ArrayTypes;

library IO;
use IO.DataType.all;
use IO.ArrayTypes.all;

library Jet;
use Jet.DataType;
use Jet.ArrayTypes;

use work.PkgConstants.all;

entity JetAlgo is
port(
    clk : in std_logic;
    D : in IO.ArrayTypes.Vector;
    Q : out IO.ArrayTypes.Vector
);
end JetAlgo;

architecture rtl of JetAlgo is

    signal DWait : Vector(0 to NPARTICLES-1) := NullVector(NPARTICLES);
    signal loop_parts_in : Vector(0 to NPARTICLES-1) := NullVector(NPARTICLES);
    signal loop_parts_out : Vector(0 to NPARTICLES-1) := NullVector(NPARTICLES);
    signal partialParts : Vector(0 to NPARTICLES-1) := NullVector(NPARTICLES);
    signal seed_eta : tData := cNull;
    signal seed_phi : tData := cNull;
    signal n_iter : Int.ArrayTypes.Vector(0 to JETLOOPLATENCY) := Int.ArrayTypes.NullVector(JETLOOPLATENCY+1);
    signal n_iter_o : Int.ArrayTypes.Vector(0 to EVENTSINFLIGHT-1) := Int.ArrayTypes.NullVector(EVENTSINFLIGHT);
    -- an index to track which event the particles & jets belong to
    -- this is complicated: we want to track the event at the end of the full jet chain
    -- so the loop and the compute latency combined
    -- but the feedback to the beginning comes after the loop latency only
    -- then make the whole thing a bit longer to simplify picking the end later
    signal n_events : Int.ArrayTypes.Vector(0 to JETLOOPLATENCY+JETCOMPUTELATENCY+2) := Int.ArrayTypes.NullVector(JETLOOPLATENCY+JETCOMPUTELATENCY+3);
    signal n_event : Int.DataType.tData := Int.DataType.cNull;
    signal jet_slv : tData := cNull;
    signal jet_o : Jet.DataType.tData := Jet.DataType.cNull;
    signal jets_all : Jet.ArrayTypes.Matrix(0 to EVENTSINFLIGHT-1)(0 to NJETS-1) := Jet.ArrayTypes.NullMatrix(EVENTSINFLIGHT, NJETS);
    signal Qint : Jet.ArrayTypes.Vector(0 to NJETS-1) := Jet.ArrayTypes.NullVector(NJETS);
    signal QintPipe : Jet.ArrayTypes.VectorPipe(0 to 4)(0 to NJETS-1) := Jet.ArrayTypes.NullVectorPipe(5, NJETS);

begin

    process(clk) is
    begin
        if rising_edge(clk) then
            -- if there's data in the FIFO and the next slot is free, start counting
            -- count from 1 so 0 can be used for 'no-event'
            if DWait(0).DataValid and n_iter(JETLOOPLATENCY).x = 0 then
                loop_parts_in <= DWait;
                n_iter(0).x <= 1;
                if n_event.x = EVENTSINFLIGHT then
                    n_event.x <= 1;
                    n_events(0).x <= 1;
                    n_events(0).DataValid <= True;
                else
                    n_event.x <= n_event.x + 1;
                    n_events(0).x <= n_event.x + 1;
                    n_events(0).DataValid <= True;
                end if;
            -- If there's no new event, and no data looping around
            -- Inject null data
            elsif n_iter(JETLOOPLATENCY).x = 0 then
                loop_parts_in <= NullVector(NPARTICLES);
                n_iter(0).x <= 0;
                n_events(0) <= Int.DataType.cNull;
            -- Otherwise an event is looping around
            else
                loop_parts_in <= loop_parts_out;
                -- if it's had NJETS iterations, it's finished
                if n_iter(JETLOOPLATENCY).x = NJETS then
                    n_iter(0).x <= 0;
                    n_events(0).x <= 0;
                    n_events(0).DataValid <= False;
                -- if it's a jet in progress, increment the counter
                elsif n_iter(JETLOOPLATENCY).x > 0 then
                    n_iter(0).x <= n_iter(JETLOOPLATENCY).x + 1;
                    -- feedback to the start after the loop latency only
                    n_events(0) <= n_events(JETLOOPLATENCY);
                else
                    n_iter(0).x <= 0;
                    n_events(0) <= Int.DataType.cNull;
                end if;
            end if;
            n_iter(1 to JETLOOPLATENCY) <= n_iter(0 to JETLOOPLATENCY-1);
            n_events(1 to JETLOOPLATENCY+JETCOMPUTELATENCY+2) <= n_events(0 to JETLOOPLATENCY+JETCOMPUTELATENCY+2-1);
            -- Write new inputs into the internal FIFO
            -- It will (should) -always- be read before the next arrives
            if D(0).DataValid then
                DWait <= D;
            -- When the internal FIFO is read into the algo, clear it
            elsif DWait(0).DataValid and n_iter(JETLOOPLATENCY).x = 0 then
                DWait <= NullVector(NPARTICLES);
            end if;
        end if;
    end process;

    JetLoop : entity work.JetLoopWrapped
    port map(clk, loop_parts_in, loop_parts_out, partialParts, seed_eta, seed_phi);

    JetCompute : entity work.JetComputeWrapped
    port map(clk, partialParts, seed_eta, seed_phi, jet_slv);

    jet_o.pt <= Jet.DataType.ToDataType(jet_slv.data).pt;
    jet_o.eta <= Jet.DataType.ToDataType(jet_slv.data).eta;
    jet_o.phi <= Jet.DataType.ToDataType(jet_slv.data).phi;
    jet_o.DataValid <= n_iter(JETLOOPLATENCY-1).x /= NJETS;

    GenJetSorts:
    for i in 0 to EVENTSINFLIGHT-1 generate
        signal jet_ev : Jet.DataType.tData := Jet.DataType.cNull;
    begin
        PickProck:
        process(clk) is
        begin
        if rising_edge(clk) then
            if n_events(JETLOOPLATENCY+JETCOMPUTELATENCY).x = i+1 then
                jet_ev.pt <= jet_o.pt;
                jet_ev.eta <= jet_o.eta;
                jet_ev.phi <= jet_o.phi;
                jet_ev.DataValid <= True;
                jet_ev.FrameValid <= True;
                if n_iter_o(i).x = NJETS then
                    n_iter_o(i).x <= 0;
                else
                    n_iter_o(i).x <= n_iter_o(i).x + 1;
                end if;
            else
                jet_ev.pt <= Jet.DataType.cNull.pt;
                jet_ev.eta <= Jet.DataType.cNull.eta;
                jet_ev.phi <= Jet.DataType.cNull.phi;
                jet_ev.DataValid <= False;
                jet_ev.FrameValid <= False;
            end if;
        end if;
        end process;
        Sort : entity work.AccumulatingSort
        port map(clk, jet_ev, jets_all(i));
    end generate;

    -- When the final jet of the event has propagated through the stream sort
    -- the last element of the output array will be valid.
    -- At that moment output the jets
    OutProc:
    process(clk) is
        variable any_valid : boolean := false;
    begin
    if rising_edge(clk) then
        any_valid := false;
        OutLoop:
        for i in 0 to EVENTSINFLIGHT-1 loop
            if jets_all(i)(NJETS-1).DataValid then
                Qint <= jets_all(i);
                any_valid := true;
            end if;
        end loop;
        if not any_valid then
            Qint <= Jet.ArrayTypes.NullVector(NJETS);
        end if;
    end if;
    end process;

    QPipe : entity Jet.DataPipe
    port map(clk, Qint, QintPipe);

    GenO:
    for i in 0 to NJETS-1 generate
        process(clk)
        begin
        if rising_edge(clk) then
            if QintPipe(0)(NJETS-1).FrameValid and not QintPipe(1)(NJETS-1).FrameValid then
                Q(i).data <= IO.DataType.ToDataType(Jet.DataType.ToStdLogicVector(QIntPipe(0)(i))).data;
                Q(i).DataValid <= QIntPipe(0)(i).DataValid;
                Q(i).FrameValid <= QIntPipe(0)(i).FrameValid;
            else
                Q(i) <= cNull;
            end if;
        end if;
        end process;
    end generate;

    -- Debug file output
    Debug : entity Int.Debug
    generic map("n_events", "./")
    port map(clk, n_events);

end rtl;

     
