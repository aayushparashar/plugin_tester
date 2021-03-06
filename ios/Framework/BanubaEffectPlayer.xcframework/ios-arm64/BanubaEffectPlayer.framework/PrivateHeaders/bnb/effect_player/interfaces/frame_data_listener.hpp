/// \file
/// \addtogroup EffectPlayer
/// @{
///
// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from effect_player.djinni

#pragma once

#include "bnb/types/interfaces/frame_data.hpp"
#include <bnb/utils/defs.hpp>
#include <memory>

namespace bnb { namespace interfaces {

/** Callback to get freshly processed frame_data. */
class BNB_EXPORT frame_data_listener {
public:
    virtual ~frame_data_listener() {}

    /** Will be called only when amount of found faces changes. */
    virtual void on_frame_data_processed(const std::shared_ptr<::bnb::interfaces::frame_data> & frame_data) = 0;
};

} }  // namespace bnb::interfaces
/// @}

