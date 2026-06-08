package app.lms.block.service;

import app.lms.block.dto.*;
import app.lms.block.mapper.BlockMapper;
import app.lms.block.model.Block;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;



@Service
@RequiredArgsConstructor
public class BlockService {


    private final BlockMapper blockMapper;
    private final BlockAccessService blockAccessService;


    public BlockPublicResponse getBlock(Long blockId, User user) {
        Block block = blockAccessService.getAccessibleBlock(blockId, user);
        return blockMapper.toPublicResponse(block);
    }
}
