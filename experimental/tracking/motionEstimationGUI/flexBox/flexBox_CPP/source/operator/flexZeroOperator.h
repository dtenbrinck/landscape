#ifndef flexZeroOperator_H
#define flexZeroOperator_H

#include <vector>
#include "flexLinearOperator.h"

template<typename T>
class flexZeroOperator : public flexLinearOperator<T>
{

#ifdef __CUDACC__
	typedef thrust::device_vector<T> Tdata;
#else
	typedef std::vector<T> Tdata;
#endif

public:
	flexZeroOperator(int aNumRows, int aNumCols, bool _minus) : flexLinearOperator<T>(aNumRows, aNumCols, zeroOp, _minus){};

	flexZeroOperator<T>* copy()
	{
		flexZeroOperator<T>* A = new flexZeroOperator<T>(this->getNumRows(), this->getNumCols(), this->isMinus);

		return A;
	}


	//apply linear operator to vector
	void times(bool transposed, const Tdata &input, Tdata &output)
	{
		vectorScalarSet(output, (T)0);
	}

	void timesPlus(bool transposed, const Tdata &input, Tdata &output){}

	void timesMinus(bool transposed, const Tdata &input, Tdata &output){}

	T getMaxRowSumAbs(bool transposed)
	{
		return static_cast<T>(1);
	}

	std::vector<T> getAbsRowSum(bool transposed)
	{
		std::vector<T> result(this->getNumRows(),(T)0);

		return result;
	}

	#ifdef __CUDACC__
	thrust::device_vector<T> getAbsRowSumCUDA(bool transposed)
	{
		Tdata result(this->getNumRows(),(T)0);

		if (transposed)
		{
			result.resize(this->getNumCols());
		}
		
		return result;
	}
	#endif
};

#endif
