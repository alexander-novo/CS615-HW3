# source `modules.sh` before attempting to build or run.

CXX = g++

# upcxx-meta PPFLAGS are really CFLAGS to be used during compilation
# upcxx-meta LDFLAGS are really CFLAGS to be used during linking
# upcxx-meta LIBFLAGS are really a combination of LDLIBS and LDFLAGS

CXXFLAGS = `upcxx-meta PPFLAGS` `upcxx-meta LDFLAGS`
LDFLAGS = `upcxx-meta LIBFLAGS`

#all: kmer_hash kmer_strong_single_test.dat
# Bridges targets
all: kmer_hash bridges

kmer_hash: kmer_hash.cpp kmer_t.hpp pkmer_t.hpp packing.hpp read_kmers.hpp hash_map.hpp butil.hpp
	$(CXX) kmer_hash.cpp -o kmer_hash $(CXXFLAGS) $(LDFLAGS)

kmer_hash_19: kmer_hash.cpp kmer_t.hpp pkmer_t.hpp packing.hpp read_kmers.hpp hash_map.hpp butil.hpp
	$(CXX) kmer_hash.cpp -o kmer_hash_19 $(CXXFLAGS) $(LDFLAGS) -DKMER_LEN=19

kmer_hash_51: kmer_hash.cpp kmer_t.hpp pkmer_t.hpp packing.hpp read_kmers.hpp hash_map.hpp butil.hpp
	$(CXX) kmer_hash.cpp -o kmer_hash_51 $(CXXFLAGS) $(LDFLAGS) -DKMER_LEN=51

kmer_strong_single_test.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 data/test.txt data > kmer_strong_single_test.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 data/test.txt data >> kmer_strong_single_test.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 data/test.txt data >> kmer_strong_single_test.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 data/test.txt data >> kmer_strong_single_test.dat

kmer_strong_single_tiny.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 data/smaller/tiny.txt data > kmer_strong_single_tiny.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 data/smaller/tiny.txt data >> kmer_strong_single_tiny.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 data/smaller/tiny.txt data >> kmer_strong_single_tiny.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 data/smaller/tiny.txt data >> kmer_strong_single_tiny.dat

kmer_strong_single_verysmall.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 data/smaller/verysmall.txt data > kmer_strong_single_verysmall.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 data/smaller/verysmall.txt data >> kmer_strong_single_verysmall.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 data/smaller/verysmall.txt data >> kmer_strong_single_verysmall.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 data/smaller/verysmall.txt data >> kmer_strong_single_verysmall.dat

kmer_strong_single_little.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 data/smaller/little.txt data > kmer_strong_single_little.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 data/smaller/little.txt data >> kmer_strong_single_little.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 data/smaller/little.txt data >> kmer_strong_single_little.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 data/smaller/little.txt data >> kmer_strong_single_little.dat

kmer_strong_single_small.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 data/smaller/small.txt data > kmer_strong_single_small.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 data/smaller/small.txt data >> kmer_strong_single_small.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 data/smaller/small.txt data >> kmer_strong_single_small.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 data/smaller/small.txt data >> kmer_strong_single_small.dat

kmer_strong_single_large.dat: kmer_hash_51
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_51 data/large.txt data > kmer_strong_single_large.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_51 data/large.txt data >> kmer_strong_single_large.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_51 data/large.txt data >> kmer_strong_single_large.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_51 data/large.txt data >> kmer_strong_single_large.dat

kmer_strong_single_human-chr14-synthetic.dat: kmer_hash_51
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_51 data/human-chr14-synthetic.txt data > kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_51 data/human-chr14-synthetic.txt data >> kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_51 data/human-chr14-synthetic.txt data >> kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_51 data/human-chr14-synthetic.txt data >> kmer_strong_single_human-chr14-synthetic.dat

#############################################	Bridges targets below	########################################################
bridges_kmer_strong_single_test.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data > ./output/single/kmer_strong_single_test.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data >> ./output/single/kmer_strong_single_test.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data >> ./output/single/kmer_strong_single_test.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data >> ./output/single/kmer_strong_single_test.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data >> ./output/single/kmer_strong_single_test.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data >> ./output/single/kmer_strong_single_test.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/test.txt data >> ./output/single/kmer_strong_single_test.dat

bridges_kmer_strong_single_tiny.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data > ./output/single/kmer_strong_single_tiny.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data >> ./output/single/kmer_strong_single_tiny.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data >> ./output/single/kmer_strong_single_tiny.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data >> ./output/single/kmer_strong_single_tiny.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data >> ./output/single/kmer_strong_single_tiny.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data >> ./output/single/kmer_strong_single_tiny.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/tiny.txt data >> ./output/single/kmer_strong_single_tiny.dat

bridges_kmer_strong_single_verysmall.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data > ./output/single/kmer_strong_single_verysmall.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data >> ./output/single/kmer_strong_single_verysmall.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data >> ./output/single/kmer_strong_single_verysmall.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data >> ./output/single/kmer_strong_single_verysmall.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data >> ./output/single/kmer_strong_single_verysmall.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data >> ./output/single/kmer_strong_single_verysmall.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/verysmall.txt data >> ./output/single/kmer_strong_single_verysmall.dat

bridges_kmer_strong_single_little.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data > ./output/single/kmer_strong_single_little.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data >> ./output/single/kmer_strong_single_little.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data >> ./output/single/kmer_strong_single_little.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data >> ./output/single/kmer_strong_single_little.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data >> ./output/single/kmer_strong_single_little.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data >> ./output/single/kmer_strong_single_little.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/little.txt data >> ./output/single/kmer_strong_single_little.dat

bridges_kmer_strong_single_small.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data > ./output/single/kmer_strong_single_small.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data >> ./output/single/kmer_strong_single_small.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data >> ./output/single/kmer_strong_single_small.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data >> ./output/single/kmer_strong_single_small.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data >> ./output/single/kmer_strong_single_small.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data >> ./output/single/kmer_strong_single_small.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_19 /pylon5/sc5fp4p/bbrock/hw3-datasets/smaller/small.txt data >> ./output/single/kmer_strong_single_small.dat

bridges_kmer_strong_single_large.dat: kmer_hash_51
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data > ./output/single/kmer_strong_single_large.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data >> ./output/single/kmer_strong_single_large.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data >> ./output/single/kmer_strong_single_large.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data >> ./output/single/kmer_strong_single_large.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data >> ./output/single/kmer_strong_single_large.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data >> ./output/single/kmer_strong_single_large.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/large.txt data >> ./output/single/kmer_strong_single_large.dat

bridges_kmer_strong_single_human-chr14-synthetic.dat: kmer_hash_51
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data > ./output/single/kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data >> ./output/single/kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data >> ./output/single/kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data >> ./output/single/kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 16 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data >> ./output/single/kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 32 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data >> ./output/single/kmer_strong_single_human-chr14-synthetic.dat
	upcxx-run -n 64 -shared-heap 50% ./kmer_hash_51 /pylon5/sc5fp4p/bbrock/hw3-datasets/human-chr14-synthetic.txt data >> ./output/single/kmer_strong_single_human-chr14-synthetic.dat


bridges: bridges_kmer_strong_single_test.dat bridges_kmer_strong_single_tiny.dat bridges_kmer_strong_single_verysmall.dat bridges_kmer_strong_single_little.dat bridges_kmer_strong_single_small.dat bridges_kmer_strong_single_large.dat bridges_kmer_strong_single_human-chr14-synthetic.dat

clean:
	@rm -fv kmer_hash kmer_hash_19 kmer_hash_51
